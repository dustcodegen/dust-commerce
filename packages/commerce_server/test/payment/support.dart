import 'dart:io';

import 'package:commerce_server/commerce_server.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_server/testing.dart';

final class PaymentTestContext {
  PaymentTestContext._(this.directory, this.database, this.client);

  final Directory directory;
  final CommerceDatabase database;
  final TestClient client;

  static Future<PaymentTestContext> start() async {
    final directory = await Directory.systemTemp.createTemp('commerce_pay');
    final database = await openTestDatabase(
      '${directory.path}/commerce.db',
      options: commerceOptions,
    );
    await _seed(database);
    var counter = 0;
    final client = TestClient(
      buildApp(
        database,
        nextId: () => 'id_${++counter}',
        now: () => DateTime.utc(2026, 9, 5),
      ),
    );
    return PaymentTestContext._(directory, database, client);
  }

  Future<void> close() async {
    await client.close();
    await database.close();
    await directory.delete(recursive: true);
  }

  Future<String> placeOrder() async {
    final created = await client.post('/store/carts').send();
    final cartId =
        CartView.fromJson(created.json! as Map<String, Object?>).cart.id;
    (await (client.post('/store/carts/$cartId/line-items')
              ..json({'variant_id': 'var_small', 'quantity': 1}))
            .send())
        .assertOk();
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
    return Order.fromJson(placed.json! as Map<String, Object?>).id;
  }

  Future<TestResponse> authorize(String orderId, {String? email}) => client
      .post(
        '/store/orders/$orderId/payments'
        '?email=${email ?? 'ada@example.com'}',
      )
      .send();

  Future<TestResponse> capture(String orderId, {String? email}) => client
      .post(
        '/store/orders/$orderId/payments/capture'
        '?email=${email ?? 'ada@example.com'}',
      )
      .send();
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
    r"('var_small', 'usd', 1999)",
  );
}
