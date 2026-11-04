import 'dart:io';

import 'package:commerce_server/commerce_server.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_server/testing.dart';
import 'package:test/test.dart';

/// Checkout with a promotion applied: the discount is frozen onto the order
/// and the redemption is counted, both inside the same transaction.
void main() {
  late Directory directory;
  late CommerceDatabase database;
  late TestClient client;
  var counter = 0;

  setUp(() async {
    counter = 0;
    directory = await Directory.systemTemp.createTemp('commerce_co_promo');
    database = await openTestDatabase(
      '${directory.path}/commerce.db',
      options: commerceOptions,
    );
    await _seed(database);
    client = TestClient(
      buildApp(
        database,
        nextId: () => 'id_${++counter}',
        now: () => DateTime.utc(2026, 9, 5),
      ),
    );
  });

  tearDown(() async {
    await client.close();
    await database.close();
    await directory.delete(recursive: true);
  });

  Future<String> cartWorth() async {
    final created = await client.post('/store/carts').send();
    final id = CartView.fromJson(created.json! as Map<String, Object?>).cart.id;
    (await (client.post('/store/carts/$id/line-items')
              ..json({'variant_id': 'var_small', 'quantity': 1}))
            .send())
        .assertOk();
    return id;
  }

  Future<TestResponse> apply(String cartId, String code) =>
      (client.post('/store/carts/$cartId/promotions')..json({'code': code}))
          .send();

  test('freezes the discount and counts the redemption', () async {
    final cartId = await cartWorth();
    await apply(cartId, 'SAVE10');
    (await (client.post('/store/carts/$cartId/shipping-method')
              ..json({'option_id': 'ship_standard'}))
            .send())
        .assertOk();
    (await (client.post('/store/carts/$cartId/payment-sessions')
              ..json({'provider_id': 'manual'}))
            .send())
        .assertOk();

    final placed = await (client.post('/store/checkout')
          ..json({
            'cart_id': cartId,
            'email': 'ada@example.com',
            'shipping_address': {
              'first_name': 'Ada',
              'last_name': 'Lovelace',
              'line1': '12 Analytical Way',
              'city': 'London',
              'postal_code': 'EC1A',
              'country_code': 'us',
            },
          }))
        .send();

    placed.assertCreated();
    final order = Order.fromJson(placed.json! as Map<String, Object?>);

    expect(order.discountTotal, Money.of(200, 'usd'));
    expect(order.total, Money.of(1980, 'usd'));

    final rows = await queryRaw(
      r"SELECT promotion.usage_count, orders.promotion_code "
      r"FROM promotions promotion "
      r"JOIN orders ON orders.cart_id = $1 "
      r"WHERE promotion.code = 'SAVE10'",
      [cartId],
    ).fetch(database.connection as Executor);
    expect(rows.single.readIndex<int>(0), 1);
    expect(rows.single.readIndex<String>(1), 'SAVE10');
  });
}

Future<void> _seed(CommerceDatabase database) async {
  Future<void> run(String sql) =>
      queryExecute(sql, []).execute(database.executor);

  await run(
    r"INSERT INTO regions (id, name, currency_code, tax_rate, countries) "
    r"VALUES ('reg_us', 'United States', 'usd', 1000, 'us')",
  );
  await run(
    r"INSERT INTO region_payment_providers (region_id, provider_id) "
    r"VALUES ('reg_us', 'manual')",
  );
  await run(
    r"INSERT INTO shipping_options (id, region_id, name, amount, currency_code) "
    r"VALUES ('ship_standard', 'reg_us', 'Standard', 0, 'usd')",
  );
  await run(
    r"INSERT INTO products (id, title, handle, status) VALUES "
    r"('prod_shirt', 'T-Shirt', 't-shirt', 'published')",
  );
  await run(
    r"INSERT INTO product_variants "
    r"(id, product_id, title, inventory_quantity) VALUES "
    r"('var_small', 'prod_shirt', 'Small', 50)",
  );
  await run(
    r"INSERT INTO variant_prices (variant_id, currency_code, amount) VALUES "
    r"('var_small', 'usd', 2000)",
  );
  await run(
    r"INSERT INTO promotions (id, code, type, value, currency_code, ends_at, "
    r"usage_limit, usage_count) VALUES "
    r"('p1', 'SAVE10', 'percentage', 1000, NULL, NULL, NULL, 0), "
    r"('p2', 'TENOFF', 'fixed', 1000, 'usd', NULL, NULL, 0), "
    r"('p3', 'HUGE', 'fixed', 999999, 'usd', NULL, NULL, 0), "
    r"('p4', 'LASTYEAR', 'percentage', 5000, NULL, '2025-01-01T00:00:00.000Z',"
    r" NULL, 0), "
    r"('p5', 'SPENT', 'percentage', 5000, NULL, NULL, 1, 1), "
    r"('p6', 'EUROOFF', 'fixed', 500, 'eur', NULL, NULL, 0)",
  );
}
