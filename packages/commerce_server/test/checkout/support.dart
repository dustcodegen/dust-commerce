import 'dart:io';

import 'package:commerce_server/commerce_server.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_server/testing.dart';

/// A running API with a seeded database, torn down after the test.
///
/// Shared by the checkout suites so each one holds only the behaviour it is
/// about. Identifiers and the clock are fixed, so an assertion can name an
/// order id instead of working around one.
final class CheckoutHarness {
  CheckoutHarness._(this._directory, this.database, this.client);

  /// Opens a database, seeds it, and serves the app in process.
  static Future<CheckoutHarness> start({
    OrderTransferMailer orderTransferMailer =
        const UnavailableOrderTransferMailer(),
    DateTime Function()? now,
  }) async {
    final directory = await Directory.systemTemp.createTemp('commerce_co');
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
        now: now ?? () => DateTime.utc(2100, 1, 1, 12),
        orderTransferMailer: orderTransferMailer,
      ),
    );

    return CheckoutHarness._(directory, database, client);
  }

  final Directory _directory;

  /// The open database, for assertions that read rows directly.
  final CommerceDatabase database;

  /// The API under test.
  final TestClient client;

  /// Closes everything this harness opened.
  Future<void> stop() async {
    await client.close();
    await database.close();
    await _directory.delete(recursive: true);
  }

  /// A well-formed shipping address, optionally broken in one field.
  Map<String, Object?> address({
    String firstName = 'Ada',
    String? company,
    String? line2,
    String? province,
    String? phone,
  }) =>
      {
        'first_name': firstName,
        'last_name': 'Lovelace',
        'company': company,
        'line1': '12 Analytical Way',
        'line2': line2,
        'city': 'London',
        'province': province,
        'postal_code': 'EC1A',
        'country_code': 'us',
        'phone': phone,
      };

  /// Starts a cart holding [quantity] of [variantId].
  Future<String> cartWith(
    String variantId, {
    int quantity = 1,
    String? token,
  }) async {
    final request = client.post('/store/carts');
    if (token != null) request.bearer(token);
    final created = await request.send();
    final cartId =
        CartView.fromJson(created.json! as Map<String, Object?>).cart.id;
    final add = client.post('/store/carts/$cartId/line-items')
      ..json({'variant_id': variantId, 'quantity': quantity});
    if (token != null) add.bearer(token);
    (await add.send()).assertOk();
    return cartId;
  }

  /// Places [cartId] as an order.
  Future<TestResponse> checkout(
    String cartId, {
    String email = 'ada@example.com',
    Map<String, Object?>? shipping,
    Map<String, Object?>? billing,
    String? token,
  }) {
    return _checkoutAfterPayment(
      cartId,
      email: email,
      shipping: shipping,
      billing: billing,
      token: token,
    );
  }

  Future<TestResponse> _checkoutAfterPayment(
    String cartId, {
    required String email,
    Map<String, Object?>? shipping,
    Map<String, Object?>? billing,
    String? token,
  }) async {
    await chooseStandardShipping(cartId, token: token);
    final payment = client.post('/store/carts/$cartId/payment-sessions')
      ..json({'provider_id': 'manual'});
    if (token != null) payment.bearer(token);
    await payment.send();

    final request = client.post('/store/checkout')
      ..json({
        'cart_id': cartId,
        'email': email,
        'shipping_address': shipping ?? address(),
        if (billing != null) 'billing_address': billing,
      });
    if (token != null) request.bearer(token);
    return request.send();
  }

  /// Selects the fixture's zero-cost standard delivery method.
  Future<TestResponse> chooseStandardShipping(
    String cartId, {
    String? token,
  }) async {
    final shipping = client.post('/store/carts/$cartId/shipping-method')
      ..json({'option_id': 'ship_standard'});
    if (token != null) shipping.bearer(token);
    return shipping.send();
  }

  /// Registers and signs in one customer, returning the durable id and token.
  Future<({String customerId, String token})> account(String email) async {
    final registered = await (client.post('/store/customers')
          ..json({
            'email': email,
            'password': 'correct horse battery staple',
            'first_name': 'Test',
            'last_name': 'Customer',
          }))
        .send();
    registered.assertCreated();

    final signedIn = await (client.post('/auth/customer/emailpass')
          ..json({
            'email': email,
            'password': 'correct horse battery staple',
          }))
        .send();
    signedIn.assertOk();

    return (
      customerId: ((registered.json! as Map<String, Object?>)['customer']!
          as Map<String, Object?>)['id']! as String,
      token: (signedIn.json! as Map<String, Object?>)['token']! as String,
    );
  }

  /// The stock on hand for [variantId], read straight from the table.
  Future<int> stockOf(String variantId) async {
    final rows = await queryRaw(
      'SELECT inventory_quantity FROM product_variants WHERE id = \$1',
      [variantId],
    ).fetch(database.connection as Executor);
    return rows.single.readIndex<int>(0);
  }
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
    r"('var_small', 'prod_shirt', 'Small', 50), "
    r"('var_large', 'prod_shirt', 'Large', 2)",
  );
  await run(
    r"INSERT INTO variant_prices (variant_id, currency_code, amount) VALUES "
    r"('var_small', 'usd', 1999), "
    r"('var_large', 'usd', 2199)",
  );
}
