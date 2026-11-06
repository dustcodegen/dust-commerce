import 'package:commerce_server/commerce_server.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:test/test.dart';

import 'support.dart';

void main() {
  late PaymentTestContext context;

  setUp(() async => context = await PaymentTestContext.start());
  tearDown(() => context.close());

  group('POST /store/orders/{id}/payments/capture', () {
    test('keeps display numbers short and monotonic', () async {
      await context.placeOrder();
      final secondOrderId = await context.placeOrder();
      await context.authorize(secondOrderId);

      final response = await context.capture(secondOrderId);

      response.assertOk();
      final order = Order.fromJson(response.json! as Map<String, Object?>);
      expect(order.displayId, 2);
      expect(order.id, secondOrderId);
    });

    test('captures without completing the order', () async {
      final orderId = await context.placeOrder();
      (await context.authorize(orderId)).assertCreated();

      final response = await context.capture(orderId);

      response.assertOk();
      final order = Order.fromJson(response.json! as Map<String, Object?>);
      expect(order.paymentStatus, PaymentStatus.captured);
      expect(order.status, OrderStatus.pending);
      expect(order.isPaid, isTrue);
      expect(order.displayId, 1);
      expect(order.payment?.providerId, 'manual');
      expect(
        order.payment?.amount,
        const Money(amount: 2199, currencyCode: 'usd'),
      );
      expect(order.payment?.createdAt.isUtc, isTrue);
    });

    test('persists the captured state independently', () async {
      final orderId = await context.placeOrder();
      await context.authorize(orderId);
      await context.capture(orderId);

      final rows = await queryRaw(
        'SELECT status, payment_status FROM orders WHERE id = ?',
        [orderId],
      ).fetch(context.database.connection as Executor);
      expect(rows.single.readIndex<String>(0), 'pending');
      expect(rows.single.readIndex<String>(1), 'captured');
    });

    test('returns the paid open order when capture is retried', () async {
      final orderId = await context.placeOrder();
      await context.authorize(orderId);
      (await context.capture(orderId)).assertOk();

      final retried = await context.capture(orderId);
      retried.assertOk();
      final order = Order.fromJson(retried.json! as Map<String, Object?>);
      expect(order.paymentStatus, PaymentStatus.captured);
      expect(order.status, OrderStatus.pending);
      expect(order.payment?.providerId, 'manual');
      expect(order.payment?.amount.amount, 2199);
    });

    test('refuses to capture what was never authorised', () async {
      final orderId = await context.placeOrder();

      (await context.capture(orderId)).assertConflict();
    });

    test('does not capture payment after an order is archived', () async {
      final orderId = await context.placeOrder();
      await context.authorize(orderId);
      await queryExecute(
        r"UPDATE orders SET status = 'archived' WHERE id = $1",
        [orderId],
      ).execute(context.database.executor);

      (await context.capture(orderId)).assertConflict();
      final rows = await queryRaw(
        'SELECT status FROM payment_collections WHERE order_id = ?',
        [orderId],
      ).fetch(context.database.connection as Executor);
      expect(rows.single.readIndex<String>(0), 'authorized');
    });

    test("will not capture somebody else's order", () async {
      final orderId = await context.placeOrder();
      await context.authorize(orderId);

      (await context.capture(orderId, email: 'grace@example.com'))
          .assertNotFound();
    });
  });
}
