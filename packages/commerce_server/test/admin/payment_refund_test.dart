import 'package:test/test.dart';

import 'payment_refund_support.dart';

void main() {
  late PaymentRefundScenario scenario;

  setUp(() async => scenario = await PaymentRefundScenario.start());
  tearDown(() => scenario.stop());

  test('refund routes require a proven Admin bearer', () async {
    (await scenario.refund({'amount': 500}, authenticated: false))
        .assertUnauthorized();
    (await scenario.harness.client.get('/admin/refund-reasons').send())
        .assertUnauthorized();
  });

  test('lists deterministic merchant refund reasons', () async {
    final request = scenario.harness.client.get('/admin/refund-reasons')
      ..bearer(await scenario.harness.adminToken());

    final response = await request.send();

    response.assertOk();
    final body = response.json! as Map<String, Object?>;
    expect(body, containsPair('count', 4));
    final reasons = body['refund_reasons']! as List<Object?>;
    expect(reasons, hasLength(4));
    expect(reasons.first, containsPair('label', 'Damaged'));
  });

  test('records partial amount reason note actor and database time', () async {
    final response = await scenario.refund({
      'amount': 725,
      'refund_reason_id': 'refund_reason_damaged',
      'note': 'Seal broken',
    });

    response.assertOk();
    final payment = response.json! as Map<String, Object?>;
    expect(payment, containsPair('id', 'pay_detail'));
    expect(payment, containsPair('refunded_amount', 725));
    expect(payment, containsPair('status', 'captured'));
    final refunds = payment['refunds']! as List<Object?>;
    final refund = refunds.single! as Map<String, Object?>;
    expect(refund, containsPair('amount', 725));
    expect(refund, containsPair('note', 'Seal broken'));
    expect(refund['refund_reason'], containsPair('label', 'Damaged'));
    final rows = await scenario.harness.raw('''
SELECT refund_reason_id, note, created_by, created_at FROM refunds
WHERE payment_collection_id = 'pay_detail'
''');
    expect(rows.single.readIndex<String>(0), 'refund_reason_damaged');
    expect(rows.single.readIndex<String>(1), 'Seal broken');
    expect(rows.single.readIndex<String>(2), 'admin_1');
    expect(rows.single.readIndex<DateTime>(3).toUtc().isUtc, isTrue);
    expect(await scenario.orderPaymentStatus(), 'captured');
  });

  test('omitted amount refunds the remaining captured funds', () async {
    (await scenario.refund({'amount': 725})).assertOk();

    final response = await scenario.refund({});

    response.assertOk();
    expect(response.json, containsPair('refunded_amount', 5400));
    expect(await scenario.orderPaymentStatus(), 'refunded');
    expect(await scenario.refundedAmount(), 5400);
  });

  test('concurrent full refunds commit exactly once', () async {
    final token = await scenario.harness.adminToken();

    final responses = await Future.wait([
      scenario.refund({}, token: token),
      scenario.refund({}, token: token),
    ]);

    expect(responses.map((value) => value.statusCode).toList()..sort(),
        [200, 409]);
    expect(await scenario.refundCount(), 1);
    expect(await scenario.refundedAmount(), 5400);
  });

  test('later cancellation refunds only the remaining balance', () async {
    (await scenario.refund({'amount': 725})).assertOk();
    await scenario.harness.raw('''
UPDATE orders SET status = 'pending' WHERE id = 'ord_detail'
''');
    await scenario.harness.raw('''
UPDATE fulfillments SET canceled_at = created_at, canceled_by = 'admin_1'
WHERE id = 'ful_detail'
''');
    final request = scenario.harness.client
        .post('/admin/orders/ord_detail/cancel')
      ..bearer(await scenario.harness.adminToken());

    (await request.send()).assertOk();

    expect(await scenario.refundedAmount(), 5400);
    expect(await scenario.refundCount(), 2);
  });

  test('rejects over-refund and unavailable reason before writes', () async {
    (await scenario.refund({'amount': 5401})).assertStatus(422);
    (await scenario.refund({
      'amount': 500,
      'refund_reason_id': 'refund_reason_missing_record',
    }))
        .assertStatus(422);

    expect(await scenario.refundCount(), 0);
  });

  test('rejects unknown command keys and unsupported providers', () async {
    (await scenario.refund({'amount': 500, 'metadata': {}})).assertStatus(422);
    await scenario.harness.raw('''
UPDATE payment_collections SET provider = 'external' WHERE id = 'pay_detail'
''');

    (await scenario.refund({'amount': 500})).assertStatus(503);
    expect(await scenario.refundCount(), 0);
  });
}
