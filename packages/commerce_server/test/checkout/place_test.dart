import 'package:commerce_server/commerce_server.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:test/test.dart';

import 'support.dart';

void main() {
  late CheckoutHarness harness;

  setUp(() async => harness = await CheckoutHarness.start());
  tearDown(() async => harness.stop());

  group('POST /store/checkout', () {
    test('binds an authenticated cart and order to the customer', () async {
      final account = await harness.account('ada@example.com');
      final cartId = await harness.cartWith(
        'var_small',
        token: account.token,
      );

      final placed = await harness.checkout(
        cartId,
        email: 'spoofed@example.com',
        token: account.token,
      );
      placed.assertCreated();
      final order = Order.fromJson(placed.json! as Map<String, Object?>);

      expect(order.customerId, account.customerId);
      expect(order.email, 'ada@example.com');
      final rows = await queryRaw(
        'SELECT customer_id, email FROM carts WHERE id = \$1',
        [cartId],
      ).fetch(harness.database.connection as Executor);
      expect(rows.single.readIndex<String>(0), account.customerId);
      expect(rows.single.readIndex<String>(1), 'ada@example.com');
    });

    test('hides a customer cart from another signed-in customer', () async {
      final ada = await harness.account('ada@example.com');
      final grace = await harness.account('grace@example.com');
      final cartId = await harness.cartWith('var_small', token: ada.token);

      (await harness.checkout(cartId, token: grace.token)).assertNotFound();
    });

    test('turns a cart into an order with frozen totals', () async {
      final cartId = await harness.cartWith('var_small', quantity: 2);

      final response = await harness.checkout(cartId);

      response.assertCreated();
      final order = Order.fromJson(response.json! as Map<String, Object?>);

      expect(order.items, hasLength(1));
      expect(order.subtotal, Money.of(3998, 'usd'));
      expect(order.tax, Money.of(400, 'usd'));
      expect(order.total, Money.of(4398, 'usd'));
      expect(order.status, OrderStatus.pending);
      expect(order.paymentStatus, PaymentStatus.awaiting);
    });

    test('takes the stock it sold', () async {
      final cartId = await harness.cartWith('var_large', quantity: 2);

      (await harness.checkout(cartId)).assertCreated();

      expect(await harness.stockOf('var_large'), 0);
    });

    test('empties and closes the cart it ordered', () async {
      final cartId = await harness.cartWith('var_small');

      (await harness.checkout(cartId)).assertCreated();

      final rows = await queryRaw(
        r'SELECT (SELECT COUNT(*) FROM line_items WHERE cart_id = $1), '
        r'completed_at FROM carts WHERE id = $1',
        [cartId],
      ).fetch(harness.database.connection as Executor);
      expect(rows.single.readIndex<int>(0), 0);
      expect(rows.single.readIndex<DateTime?>(1), isNotNull);
      (await harness.client.get('/store/carts/$cartId').send())
          .assertNotFound();
    });

    test('returns the same order when checkout is retried', () async {
      final cartId = await harness.cartWith('var_small', quantity: 2);

      final first = await harness.checkout(cartId);
      final retried = await harness.checkout(cartId);

      first.assertCreated();
      retried.assertCreated();
      final firstOrder = Order.fromJson(first.json! as Map<String, Object?>);
      final retriedOrder =
          Order.fromJson(retried.json! as Map<String, Object?>);
      expect(retriedOrder.id, firstOrder.id);
      expect(await harness.stockOf('var_small'), 48);

      final rows = await queryRaw(
        'SELECT COUNT(orders.id), MAX(carts.completed_at) FROM carts '
        'LEFT JOIN orders ON orders.cart_id = carts.id WHERE carts.id = \$1',
        [cartId],
      ).fetch(harness.database.connection as Executor);
      expect(rows.single.readIndex<int>(0), 1);
      expect(rows.single.readIndex<DateTime?>(1), isNotNull);
    });
  });

  group('when somebody else got there first', () {
    test('answers 409 and takes no more stock', () async {
      final mine = await harness.cartWith('var_large', quantity: 2);
      final theirs = await harness.cartWith('var_large', quantity: 2);

      (await harness.checkout(theirs)).assertCreated();
      (await harness.checkout(mine)).assertConflict();

      expect(await harness.stockOf('var_large'), 0);
    });

    test('leaves no order behind', () async {
      final mine = await harness.cartWith('var_large', quantity: 2);
      final theirs = await harness.cartWith('var_large', quantity: 2);

      (await harness.checkout(theirs)).assertCreated();
      (await harness.checkout(mine, email: 'loser@example.com'))
          .assertConflict();

      final rows = await queryRaw(
        'SELECT COUNT(*) FROM orders WHERE email = \$1',
        ['loser@example.com'],
      ).fetch(harness.database.connection as Executor);
      expect(rows.single.readIndex<int>(0), 0);
    });
  });

  group('what it refuses', () {
    test('an invalid bearer token cannot downgrade to a guest', () async {
      final request = harness.client.post('/store/carts')
        ..bearer('not-a-real-token');

      (await request.send()).assertUnauthorized();
    });

    test('a cart nobody started', () async {
      (await harness.checkout('nope')).assertNotFound();
    });

    test('an empty cart', () async {
      final created = await harness.client.post('/store/carts').send();
      final cartId =
          CartView.fromJson(created.json! as Map<String, Object?>).cart.id;

      (await harness.checkout(cartId)).assertUnprocessable();
    });

    test('a cart without a payment selection', () async {
      final cartId = await harness.cartWith('var_small');
      (await harness.chooseStandardShipping(cartId)).assertOk();

      final response = await (harness.client.post('/store/checkout')
            ..json({
              'cart_id': cartId,
              'email': 'ada@example.com',
              'shipping_address': harness.address(),
            }))
          .send();

      response
        ..assertUnprocessable()
        ..assertJsonContains({
          'error': 'Select a payment method before checkout',
        });
    });

    test('a cart without a delivery selection', () async {
      final cartId = await harness.cartWith('var_small');
      final payment = harness.client
          .post('/store/carts/$cartId/payment-sessions')
        ..json({'provider_id': 'manual'});
      (await payment.send()).assertOk();

      final response = await (harness.client.post('/store/checkout')
            ..json({
              'cart_id': cartId,
              'email': 'ada@example.com',
              'shipping_address': harness.address(),
            }))
          .send();

      response
        ..assertUnprocessable()
        ..assertJsonContains({
          'error': 'Select a delivery method before checkout',
        });
      expect(await harness.stockOf('var_small'), 50);
      final orders = await queryRaw(
        'SELECT COUNT(*) FROM orders WHERE cart_id = \$1',
        [cartId],
      ).fetch(harness.database.connection as Executor);
      expect(orders.single.readIndex<int>(0), 0);
    });

    test('a provider disabled after selection', () async {
      final cartId = await harness.cartWith('var_small');
      (await harness.chooseStandardShipping(cartId)).assertOk();
      final selected = harness.client
          .post('/store/carts/$cartId/payment-sessions')
        ..json({'provider_id': 'manual'});
      (await selected.send()).assertOk();
      await queryExecute(
        r"UPDATE region_payment_providers SET enabled = 0 "
        r"WHERE region_id = 'reg_us' AND provider_id = 'manual'",
        const [],
      ).execute(harness.database.executor);

      final request = harness.client.post('/store/checkout')
        ..json({
          'cart_id': cartId,
          'email': 'ada@example.com',
          'shipping_address': harness.address(),
        });

      (await request.send()).assertUnprocessable();
    });

    test('an address that is not an email, naming the field', () async {
      final cartId = await harness.cartWith('var_small');

      (await harness.checkout(cartId, email: 'not-an-email'))
        ..assertUnprocessable()
        ..assertJsonContains({
          'error': 'Validation failed',
          'fields': {
            'email': ['Enter a valid email address'],
          },
        });
    });

    test('a shipping address missing its recipient, named as nested', () async {
      final cartId = await harness.cartWith('var_small');

      (await harness.checkout(
        cartId,
        shipping: harness.address(firstName: ''),
      ))
        ..assertUnprocessable()
        ..assertJsonContains({
          'error': 'Validation failed',
          'fields': {
            'shippingAddress.firstName': ['Enter a first name'],
          },
        });
    });
  });
}
