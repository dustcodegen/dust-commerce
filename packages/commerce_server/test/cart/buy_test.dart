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
    directory = await Directory.systemTemp.createTemp('commerce_cart_buy');
    database = await openTestDatabase(
      '${directory.path}/commerce.db',
      options: commerceOptions,
    );
    await _seed(database);
    client = TestClient(buildApp(
      database,
      nextId: () => 'id_${++counter}',
      now: () => DateTime.utc(2026, 9, 5),
    ));
  });

  tearDown(() async {
    await client.close();
    await database.close();
    await directory.delete(recursive: true);
  });

  test('creates all permalink lines atomically', () async {
    final response = await (client.post('/store/carts/buy')
          ..json({
            'region_id': 'reg_us',
            'items': [
              {'variant_id': 'var_small', 'quantity': 2},
              {'variant_id': 'var_large', 'quantity': 1},
            ],
          }))
        .send();

    response.assertCreated();
    final cart = CartView.fromJson(response.json! as Map<String, Object?>).cart;
    expect(cart.items.map((item) => item.variantId), [
      'var_small',
      'var_large',
    ]);
    expect(cart.itemCount, 3);
  });

  test('rolls back the cart when a later line cannot be sold', () async {
    final response = await (client.post('/store/carts/buy')
          ..json({
            'region_id': 'reg_us',
            'items': [
              {'variant_id': 'var_small', 'quantity': 1},
              {'variant_id': 'missing', 'quantity': 1},
            ],
          }))
        .send();

    response.assertUnprocessable();
    (await client.get('/store/carts/id_1').send()).assertNotFound();
  });

  test('rejects malformed or over-sized item lists before writing', () async {
    (await (client.post('/store/carts/buy')
              ..json(<String, Object?>{'items': <Object?>[]}))
            .send())
        .assertUnprocessable();
    (await (client.post('/store/carts/buy')
              ..json({
                'items': [
                  {'variant_id': 'var_small', 'quantity': 101},
                ],
              }))
            .send())
        .assertUnprocessable();
  });
}

Future<void> _seed(CommerceDatabase database) async {
  Future<void> run(String sql) =>
      queryExecute(sql, []).execute(database.executor);
  await run(
    "INSERT INTO regions (id, name, currency_code, tax_rate, countries) "
    "VALUES ('reg_us', 'United States', 'usd', 1000, 'us')",
  );
  await run(
    "INSERT INTO products (id, title, handle, status) "
    "VALUES ('prod_shirt', 'T-Shirt', 't-shirt', 'published')",
  );
  await run(
    "INSERT INTO product_variants "
    "(id, product_id, title, inventory_quantity) VALUES "
    "('var_small', 'prod_shirt', 'Small', 50), "
    "('var_large', 'prod_shirt', 'Large', 2)",
  );
  await run(
    "INSERT INTO variant_prices (variant_id, currency_code, amount) VALUES "
    "('var_small', 'usd', 1999), ('var_large', 'usd', 2199)",
  );
}
