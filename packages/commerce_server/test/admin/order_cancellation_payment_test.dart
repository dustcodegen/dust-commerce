import 'package:test/test.dart';

import 'order_cancellation_support.dart';

void main() {
  late OrderCancellationScenario scenario;

  setUp(() async => scenario = await OrderCancellationScenario.start());
  tearDown(() => scenario.stop());

  test('refunds captured manual payment as a separate audit record', () async {
    final response = await scenario.cancel();

    response.assertOk();
    final body = response.json! as Map<String, Object?>;
    expect(body['status'], 'canceled');
    expect(body['payment_status'], 'refunded');
    expect(body['payment_record_status'], 'canceled');
    expect(await scenario.stock(), scenario.stockBeforeOrder);
    final rows = await scenario.harness.raw('''
SELECT amount, currency_code, created_by, created_at
FROM refunds WHERE payment_collection_id = 'pay_detail'
''');
    expect(rows.single.readIndex<int>(0), 5400);
    expect(rows.single.readIndex<String>(1), 'eur');
    expect(rows.single.readIndex<String>(2), 'admin_1');
    expect(rows.single.readIndex<DateTime>(3).toUtc().isUtc, isTrue);
  });

  test('concurrent retry restores inventory and refunds exactly once',
      () async {
    final token = await scenario.harness.adminToken();

    final responses = await Future.wait([
      scenario.cancel(token: token),
      scenario.cancel(token: token),
    ]);

    expect(responses.map((response) => response.statusCode).toList()..sort(),
        [200, 422]);
    expect(await scenario.stock(), scenario.stockBeforeOrder);
    expect(await scenario.refundCount(), 1);
  });

  test('unknown payment provider fails before local writes', () async {
    await scenario.harness.raw('''
UPDATE payment_collections SET provider = 'external' WHERE id = 'pay_detail'
''');
    final reserved = await scenario.stock();

    (await scenario.cancel()).assertStatus(503);

    expect(await scenario.orderStatus(), 'pending');
    expect(await scenario.stock(), reserved);
    expect(await scenario.refundCount(), 0);
  });
}
