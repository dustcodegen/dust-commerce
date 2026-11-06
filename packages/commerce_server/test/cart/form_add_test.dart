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
    directory = await Directory.systemTemp.createTemp('commerce_cart_form');
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

  test('creates a cart and line from Medusa-compatible form fields', () async {
    final response = await (client.post('/store/cart/add')
          ..form({
            'region_id': 'reg_us',
            'variant_id': 'var_small',
            'quantity': '2',
          }))
        .send();

    response.assertOk();
    final cart = CartView.fromJson(response.json! as Map<String, Object?>).cart;
    expect(cart.items.single.variantId, 'var_small');
    expect(cart.items.single.quantity, 2);
  });

  test('adds to an existing cart capability from the same form', () async {
    final created = await client.post('/store/carts').send();
    final cartId =
        CartView.fromJson(created.json! as Map<String, Object?>).cart.id;

    final response = await (client.post('/store/cart/add')
          ..form({
            'cart_id': cartId,
            'variant_id': 'var_small',
            'quantity': '2',
          }))
        .send();

    response.assertOk();
    final cart = CartView.fromJson(response.json! as Map<String, Object?>).cart;
    expect(cart.id, cartId);
    expect(cart.items.single.quantity, 2);
  });

  test('rolls back a new cart when the variant cannot be sold', () async {
    final response = await (client.post('/store/cart/add')
          ..form({
            'region_id': 'reg_us',
            'variant_id': 'missing',
          }))
        .send();

    response.assertUnprocessable();
    (await client.get('/store/carts/id_1').send()).assertNotFound();
  });

  test('rejects an invalid quantity before creating a cart', () async {
    final response = await (client.post('/store/cart/add')
          ..form({
            'region_id': 'reg_us',
            'variant_id': 'var_small',
            'quantity': '101',
          }))
        .send();

    response.assertUnprocessable();
    (await client.get('/store/carts/id_1').send()).assertNotFound();
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
    "('var_small', 'prod_shirt', 'Small', 50)",
  );
  await run(
    "INSERT INTO variant_prices (variant_id, currency_code, amount) "
    "VALUES ('var_small', 'usd', 1999)",
  );
}
