import 'package:commerce_server/commerce_server.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:test/test.dart';

import 'support.dart';

void main() {
  late CheckoutHarness harness;

  setUp(() async => harness = await CheckoutHarness.start());
  tearDown(() async => harness.stop());

  Future<String> placeOrder(
    ({String customerId, String token}) account, {
    String email = 'ignored@example.com',
  }) async {
    final cartId = await harness.cartWith('var_small', token: account.token);
    final placed = await harness.checkout(
      cartId,
      email: email,
      token: account.token,
    );
    placed.assertCreated();
    return Order.fromJson(placed.json! as Map<String, Object?>).id;
  }

  group('GET /store/orders', () {
    test('lists only the authenticated customer orders', () async {
      final ada = await harness.account('ada@example.com');
      final grace = await harness.account('grace@example.com');
      await placeOrder(ada);
      await placeOrder(grace);

      final request = harness.client.get('/store/orders')..bearer(ada.token);
      (await request.send())
        ..assertOk()
        ..assertJsonContains({'count': 1});
    });

    test('an email query cannot replace authentication', () async {
      (await harness.client.get('/store/orders?email=ada@example.com').send())
          .assertUnauthorized();
    });
  });

  group('GET /store/orders/{id}', () {
    test('returns an order to its authenticated customer', () async {
      final ada = await harness.account('ada@example.com');
      final id = await placeOrder(ada);

      final request = harness.client.get('/store/orders/$id')
        ..bearer(ada.token);
      final response = await request.send();

      response.assertOk();
      final order = Order.fromJson(response.json! as Map<String, Object?>);

      expect(order.id, id);
      expect(order.customerId, ada.customerId);
      expect(order.email, 'ada@example.com');
      expect(order.shippingAddress.city, 'London');
      expect(order.billingAddress, order.shippingAddress);
    });

    test('keeps receipt lines in Medusa newest-first order', () async {
      final ada = await harness.account('ada@example.com');
      final cartId = await harness.cartWith(
        'var_small',
        token: ada.token,
      );
      final add = harness.client.post('/store/carts/$cartId/line-items')
        ..bearer(ada.token)
        ..json({'variant_id': 'var_large', 'quantity': 1});
      (await add.send()).assertOk();

      final placed = await harness.checkout(cartId, token: ada.token);
      placed.assertCreated();
      final order = Order.fromJson(placed.json! as Map<String, Object?>);

      await queryExecute(
        "UPDATE order_items SET created_at = CASE variant_id "
        "WHEN 'var_small' THEN TIMESTAMPTZ '2100-01-01T12:00:00Z' "
        "WHEN 'var_large' THEN TIMESTAMPTZ '2100-01-01T12:00:01Z' "
        'END WHERE order_id = \$1',
        [order.id],
      ).execute(harness.database.executor);

      final request = harness.client.get('/store/orders/${order.id}')
        ..bearer(ada.token);
      final refreshed = Order.fromJson(
        (await request.send()).json! as Map<String, Object?>,
      );

      expect(
        refreshed.items.map((item) => item.variantId),
        ['var_large', 'var_small'],
      );
    });

    test('hides an order from another authenticated customer', () async {
      final ada = await harness.account('ada@example.com');
      final grace = await harness.account('grace@example.com');
      final id = await placeOrder(ada);

      final request = harness.client.get('/store/orders/$id')
        ..bearer(grace.token);
      (await request.send()).assertNotFound();
    });

    test('requires a bearer token even when the email is supplied', () async {
      final ada = await harness.account('ada@example.com');
      final id = await placeOrder(ada);

      (await harness.client
              .get('/store/orders/$id?email=ada@example.com')
              .send())
          .assertUnauthorized();
    });
  });
}
