import 'dart:io';

import 'package:commerce_server/commerce_server.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_server/testing.dart';
import 'package:test/test.dart';

void main() {
  late Directory directory;
  late CommerceDatabase database;
  late TestClient client;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('commerce_ship_rule');
    database = await openTestDatabase(
      '${directory.path}/commerce.db',
      options: commerceOptions,
    );
    await seedDevelopmentStore(database);
    await queryExecute(
      "UPDATE shipping_option_price_rules SET value = 3000 "
      "WHERE id = 'ship_free_minimum'",
      const [],
    ).execute(database.executor);
    client = TestClient(buildApp(database));
  });

  tearDown(() async {
    await client.close();
    await database.close();
    await directory.delete(recursive: true);
  });

  Future<String> cartWithGoods(int quantity) async {
    final created = await (client.post('/store/carts')
          ..json({'region_id': 'reg_us'}))
        .send();
    final cartId =
        CartView.fromJson(created.json! as Map<String, Object?>).cart.id;
    (await (client.post('/store/carts/$cartId/line-items')
              ..json({
                'variant_id': 'var_tshirt_m_white',
                'quantity': quantity,
              }))
            .send())
        .assertOk();
    return cartId;
  }

  Future<TestResponse> chooseFree(String cartId) =>
      (client.post('/store/carts/$cartId/shipping-method')
            ..json({'option_id': 'ship_free'}))
          .send();

  test('refuses conditional free shipping below its threshold', () async {
    final response = await chooseFree(await cartWithGoods(1));

    response.assertUnprocessable();
    expect(
      (response.json! as Map<String, Object?>)['error'],
      contains('does not apply'),
    );
  });

  test('accepts conditional free shipping at its exact threshold', () async {
    final response = await chooseFree(await cartWithGoods(2));

    response
      ..assertOk()
      ..assertJsonContains({
        'shipping_total': {'amount': 0, 'currency_code': 'usd'},
      });
  });

  test('clears free shipping when a line falls below its rule', () async {
    final cartId = await cartWithGoods(2);
    (await chooseFree(cartId)).assertOk();
    final loaded = await client.get('/store/carts/$cartId').send();
    final lineId = CartView.fromJson(
      loaded.json! as Map<String, Object?>,
    ).cart.items.single.id;

    final changed = await (client.patch(
      '/store/carts/$cartId/line-items/$lineId',
    )..json({'quantity': 1}))
        .send();

    changed.assertOk();
    final body = changed.json! as Map<String, Object?>;
    expect(body['shipping_total'], {'amount': 0, 'currency_code': 'usd'});
    expect(
      (body['cart']! as Map<String, Object?>)['shipping_method'],
      isNull,
    );
  });
}
