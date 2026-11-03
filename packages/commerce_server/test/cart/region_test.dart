import 'dart:io';

import 'package:commerce_server/commerce_server.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_server/testing.dart';
import 'package:test/test.dart';

void main() {
  late Directory directory;
  late CommerceDatabase database;
  late TestClient client;
  var counter = 0;

  setUp(() async {
    counter = 0;
    directory = await Directory.systemTemp.createTemp('commerce_region');
    database = await openTestDatabase(
      '${directory.path}/commerce.db',
      options: commerceOptions,
    );
    await _seed(database);
    client = TestClient(buildApp(
      database,
      nextId: () => 'id_${++counter}',
      now: () => DateTime.utc(2026, 9, 6),
    ));
  });

  tearDown(() async {
    await client.close();
    await database.close();
    await directory.delete(recursive: true);
  });

  test('POST /store/carts creates in the explicitly selected region', () async {
    final response = await (client.post('/store/carts')
          ..json({'region_id': 'reg_eu'}))
        .send();

    response.assertCreated();
    final cart = CartView.fromJson(response.json! as Map<String, Object?>);
    expect(cart.cart.region.id, 'reg_eu');
    expect(cart.cart.region.currencyCode, 'eur');
  });

  test('PATCH region reprices lines and reconciles cart adjustments', () async {
    final cartId = await _cartWithLine(client, 'var_both');
    await _applyPromotion(client, cartId);
    await _chooseShipping(client, cartId, 'ship_us');

    final response = await (client.patch('/store/carts/$cartId')
          ..json({'region_id': 'reg_eu'}))
        .send();

    response.assertOk();
    final cart = CartView.fromJson(response.json! as Map<String, Object?>).cart;
    expect(cart.region.id, 'reg_eu');
    expect(cart.items.single.unitPrice, Money.of(1800, 'eur'));
    expect(cart.shippingMethod, isNull);
    expect(cart.promotions.single.code, 'SAVE10');
    expect(cart.promotions.single.value, 1000);
    expect(cart.discountTotal, Money.of(180, 'eur'));
  });

  test('PATCH region is atomic when a line has no regional price', () async {
    final cartId = await _cartWithLine(client, 'var_us_only');
    await _applyPromotion(client, cartId);
    await _chooseShipping(client, cartId, 'ship_us');

    final response = await (client.patch('/store/carts/$cartId')
          ..json({'region_id': 'reg_eu'}))
        .send();
    response
      ..assertUnprocessable()
      ..assertTextContains('not available in that region');

    final unchanged = await client.get('/store/carts/$cartId').send();
    final cart =
        CartView.fromJson(unchanged.json! as Map<String, Object?>).cart;
    expect(cart.region.id, 'reg_us');
    expect(cart.items.single.unitPrice, Money.of(1000, 'usd'));
    expect(cart.shippingMethod?.optionId, 'ship_us');
    expect(cart.discountTotal, Money.of(100, 'usd'));
  });

  test('PATCH region rejects an unknown region without changing the cart',
      () async {
    final cartId = await _cartWithLine(client, 'var_both');

    final response = await (client.patch('/store/carts/$cartId')
          ..json({'region_id': 'reg_missing'}))
        .send();

    response.assertUnprocessable();
    final unchanged = await client.get('/store/carts/$cartId').send();
    final cart =
        CartView.fromJson(unchanged.json! as Map<String, Object?>).cart;
    expect(cart.region.id, 'reg_us');
  });
}

Future<String> _cartWithLine(TestClient client, String variantId) async {
  final created =
      await (client.post('/store/carts')..json({'region_id': 'reg_us'})).send();
  final cartId =
      CartView.fromJson(created.json! as Map<String, Object?>).cart.id;
  (await (client.post('/store/carts/$cartId/line-items')
            ..json({'variant_id': variantId}))
          .send())
      .assertOk();
  return cartId;
}

Future<void> _applyPromotion(TestClient client, String cartId) async {
  (await (client.post('/store/carts/$cartId/promotions')
            ..json({'code': 'SAVE10'}))
          .send())
      .assertOk();
}

Future<void> _chooseShipping(
  TestClient client,
  String cartId,
  String optionId,
) async {
  (await (client.post('/store/carts/$cartId/shipping-method')
            ..json({'option_id': optionId}))
          .send())
      .assertOk();
}

Future<void> _seed(CommerceDatabase database) async {
  Future<void> run(String sql) =>
      queryExecute(sql, const []).execute(database.executor);

  await run(r"INSERT INTO regions "
      r"(id, name, currency_code, tax_rate, countries) VALUES "
      r"('reg_us', 'United States', 'usd', 0, 'us'), "
      r"('reg_eu', 'Europe', 'eur', 0, 'dk,de')");
  await run(r"INSERT INTO products (id, title, handle, status) VALUES "
      r"('prod_1', 'T-Shirt', 't-shirt', 'published')");
  await run(r"INSERT INTO product_variants "
      r"(id, product_id, title, inventory_quantity) VALUES "
      r"('var_both', 'prod_1', 'Both', 10), "
      r"('var_us_only', 'prod_1', 'US only', 10)");
  await run(r"INSERT INTO variant_prices "
      r"(variant_id, currency_code, amount) VALUES "
      r"('var_both', 'usd', 2000), ('var_both', 'eur', 1800), "
      r"('var_us_only', 'usd', 1000)");
  await run(r"INSERT INTO shipping_options "
      r"(id, region_id, name, amount, currency_code) VALUES "
      r"('ship_us', 'reg_us', 'US delivery', 500, 'usd'), "
      r"('ship_eu', 'reg_eu', 'EU delivery', 450, 'eur')");
  await run(r"INSERT INTO promotions (id, code, type, value) VALUES "
      r"('promo_10', 'SAVE10', 'percentage', 1000)");
}
