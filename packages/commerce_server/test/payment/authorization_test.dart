import 'package:commerce_server/commerce_server.dart';
import 'package:test/test.dart';

import 'support.dart';

void main() {
  late PaymentTestContext context;

  setUp(() async => context = await PaymentTestContext.start());
  tearDown(() => context.close());

  group('POST /store/orders/{id}/payments', () {
    test('starts a payment for what the order says it owes', () async {
      final orderId = await context.placeOrder();

      (await context.authorize(orderId)).assertCreated();

      final rows = await queryRaw(
        'SELECT amount, status FROM payment_collections WHERE order_id = ?',
        [orderId],
      ).fetch(context.database.connection as Executor);
      expect(rows.single.readIndex<int>(0), 2199);
      expect(rows.single.readIndex<String>(1), 'authorized');
    });

    test('reuses a payment when authorization is retried', () async {
      final orderId = await context.placeOrder();
      (await context.authorize(orderId)).assertCreated();

      (await context.authorize(orderId)).assertCreated();
      final rows = await queryRaw(
        'SELECT COUNT(*) FROM payment_collections WHERE order_id = ?',
        [orderId],
      ).fetch(context.database.connection as Executor);
      expect(rows.single.readIndex<int>(0), 1);
    });

    test('does not start payment for an archived order', () async {
      final orderId = await context.placeOrder();
      await queryExecute(
        r"UPDATE orders SET status = 'archived' WHERE id = $1",
        [orderId],
      ).execute(context.database.executor);

      (await context.authorize(orderId)).assertConflict();
    });

    test('will not let somebody else pay for a known order id', () async {
      final orderId = await context.placeOrder();

      (await context.authorize(orderId, email: 'grace@example.com'))
          .assertNotFound();
    });

    test('requires an email at all', () async {
      final orderId = await context.placeOrder();

      (await context.client.post('/store/orders/$orderId/payments').send())
          .assertBadRequest();
    });
  });
}
