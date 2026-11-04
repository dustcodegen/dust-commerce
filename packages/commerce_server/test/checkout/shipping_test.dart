import 'dart:io';

import 'package:commerce_server/commerce_server.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_server/testing.dart';
import 'package:test/test.dart';

/// Checkout with a delivery method chosen, which is the ordinary path and the
/// one where the totals have every term in them.
void main() {
  late Directory directory;
  late CommerceDatabase database;
  late TestClient client;
  var counter = 0;

  setUp(() async {
    counter = 0;
    directory = await Directory.systemTemp.createTemp('commerce_co_ship');
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

  test('freezes the shipping it was quoted', () async {
    final created = await (client.post('/store/carts')
          ..json({'region_id': 'reg_us'}))
        .send();
    final cartId =
        CartView.fromJson(created.json! as Map<String, Object?>).cart.id;

    (await (client.post('/store/carts/$cartId/line-items')
              ..json({'variant_id': 'var_small', 'quantity': 1}))
            .send())
        .assertOk();
    (await (client.post('/store/carts/$cartId/shipping-method')
              ..json({'option_id': 'so_standard'}))
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

    expect(order.subtotal, Money.of(1999, 'usd'));
    expect(order.shippingTotal, Money.of(500, 'usd'));
    expect(order.discountTotal, Money.zero('usd'));
    expect(order.tax, Money.of(250, 'usd'));
    expect(order.total, Money.of(2749, 'usd'));
    expect(order.shippingMethod?.name, 'Standard');
  });

  test('exposes pickup options with their safe store details', () async {
    final created = await (client.post('/store/carts')
          ..json({'region_id': 'reg_us'}))
        .send();
    final cartId =
        CartView.fromJson(created.json! as Map<String, Object?>).cart.id;

    final response =
        await client.get('/store/carts/$cartId/shipping-options').send();

    response.assertOk();
    final options = ShippingOptionsView.fromJson(
      response.json! as Map<String, Object?>,
    );
    final pickup = options.shippingOptions.singleWhere(
      (option) => option.fulfillmentType == ShippingFulfillmentType.pickup,
    );
    expect(pickup.pickupName, 'Morrow New York');
    expect(pickup.pickupAddress, '100 Broadway, New York, NY');

    final chosen = await (client.post(
      '/store/carts/$cartId/shipping-method',
    )..json({'option_id': 'so_pickup'}))
        .send();
    chosen.assertOk();
    final cart = CartView.fromJson(chosen.json! as Map<String, Object?>).cart;
    expect(
        cart.shippingMethod?.fulfillmentType, ShippingFulfillmentType.pickup);
    expect(cart.shippingMethod?.pickupName, 'Morrow New York');
  });

  test('keeps pickup store details on the placed order', () async {
    final created = await (client.post('/store/carts')
          ..json({'region_id': 'reg_us'}))
        .send();
    final cartId =
        CartView.fromJson(created.json! as Map<String, Object?>).cart.id;

    (await (client.post('/store/carts/$cartId/line-items')
              ..json({'variant_id': 'var_small', 'quantity': 1}))
            .send())
        .assertOk();
    (await (client.post('/store/carts/$cartId/shipping-method')
              ..json({'option_id': 'so_pickup'}))
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
    expect(order.shippingTotal, Money.zero('usd'));
    expect(
        order.shippingMethod?.fulfillmentType, ShippingFulfillmentType.pickup);
    expect(order.shippingMethod?.pickupName, 'Morrow New York');
    expect(order.shippingMethod?.pickupAddress, '100 Broadway, New York, NY');
  });
}

Future<void> _seed(CommerceDatabase database) async {
  Future<void> run(String sql) =>
      queryExecute(sql, []).execute(database.executor);

  await run(
    r"INSERT INTO regions (id, name, currency_code, tax_rate, countries) "
    r"VALUES ('reg_us', 'United States', 'usd', 1000, 'us'), "
    r"('reg_eu', 'Europe', 'eur', 2000, 'de')",
  );
  await run(
    r"INSERT INTO region_payment_providers (region_id, provider_id) "
    r"VALUES ('reg_us', 'manual'), ('reg_eu', 'manual')",
  );
  await run(
    r"INSERT INTO shipping_options (id, region_id, name, amount, currency_code)"
    r" VALUES "
    r"('so_standard', 'reg_us', 'Standard', 500, 'usd'), "
    r"('so_express', 'reg_us', 'Express', 1500, 'usd'), "
    r"('so_pickup', 'reg_us', 'Store pickup', 0, 'usd'), "
    r"('so_eu_only', 'reg_eu', 'EU post', 400, 'eur')",
  );
  await run(
    r"INSERT INTO shipping_option_fulfillments "
    r"(shipping_option_id, fulfillment_type, pickup_name, pickup_address) "
    r"VALUES ('so_pickup', 'pickup', 'Morrow New York', "
    r"'100 Broadway, New York, NY')",
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
