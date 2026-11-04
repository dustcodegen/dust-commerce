import 'package:test/test.dart';

import 'order_cancellation_support.dart';

void main() {
  late OrderCancellationScenario scenario;

  setUp(() async => scenario = await OrderCancellationScenario.start());
  tearDown(() => scenario.stop());

  test('whole-order cancellation requires the Admin route guard', () async {
    (await scenario.cancel(authenticated: false)).assertUnauthorized();

    expect(await scenario.orderStatus(), 'pending');
    expect(await scenario.refundCount(), 0);
  });

  test('cancels an unpaid order and releases managed inventory', () async {
    await scenario.makeUnpaid();

    final response = await scenario.cancel();

    response.assertOk();
    final body = response.json! as Map<String, Object?>;
    expect(body['status'], 'canceled');
    expect(body['payment_status'], 'awaiting');
    expect(body['payment_record_status'], 'canceled');
    expect(await scenario.stock(), scenario.stockBeforeOrder);
    expect(await scenario.refundCount(), 0);
    final audit = await scenario.harness.raw('''
SELECT canceled_at, canceled_by FROM orders WHERE id = 'ord_detail'
''');
    expect(audit.single.readIndex<DateTime>(0).toUtc().isUtc, isTrue);
    expect(audit.single.readIndex<String>(1), 'admin_1');
  });

  test('requires every fulfillment to be canceled first', () async {
    await scenario.activateFulfillment();
    final reserved = await scenario.stock();

    (await scenario.cancel()).assertUnprocessable();

    expect(await scenario.orderStatus(), 'pending');
    expect(await scenario.stock(), reserved);
    expect(await scenario.refundCount(), 0);
  });

  test('completed and missing orders cannot be canceled', () async {
    await scenario.completeOrder();
    (await scenario.cancel()).assertUnprocessable();

    final request = scenario.harness.client.post('/admin/orders/missing/cancel')
      ..bearer(await scenario.harness.adminToken());
    (await request.send()).assertNotFound();
  });
}
