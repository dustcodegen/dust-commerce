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
        r'SELECT customer_id, email FROM carts WHERE id = $1',
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
        r'LEFT JOIN orders ON orders.cart_id = carts.id WHERE carts.id = $1',
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
        r'SELECT COUNT(*) FROM orders WHERE email = $1',
        ['loser@example.com'],
      ).fetch(harness.database.connection as Executor);
      expect(rows.single.readIndex<int>(0), 0);
    });
  });
}
