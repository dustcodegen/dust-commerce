import 'package:test/test.dart';

import 'payment_refund_support.dart';

void main() {
  late PaymentRefundScenario scenario;

  setUp(() async => scenario = await PaymentRefundScenario.start());
  tearDown(() => scenario.stop());

  test('reason mutations require a proven Admin bearer', () async {
    final request = scenario.harness.client.post('/admin/refund-reasons')
      ..json({'label': 'Wrong size', 'code': 'wrong_size'});
    (await request.send()).assertUnauthorized();
  });

  test('creates, edits and retires a reason without erasing history', () async {
    final token = await scenario.harness.adminToken();
    final create = scenario.harness.client.post('/admin/refund-reasons')
      ..bearer(token)
      ..json({
        'label': 'Wrong size',
        'code': 'wrong_size',
        'description': 'Customer selected the wrong size.',
      });
    final created = await create.send();

    created.assertStatus(201);
    final createdBody = created.json! as Map<String, Object?>;
    expect(createdBody, containsPair('code', 'wrong_size'));
    expect(createdBody,
        containsPair('description', 'Customer selected the wrong size.'));
    final id = createdBody['id']! as String;

    final refund =
        scenario.harness.client.post('/admin/payments/pay_detail/refund')
          ..bearer(token)
          ..json({'amount': 100, 'refund_reason_id': id});
    (await refund.send()).assertOk();

    final duplicate = scenario.harness.client.post('/admin/refund-reasons')
      ..bearer(token)
      ..json({'label': 'Other', 'code': 'wrong_size'});
    (await duplicate.send()).assertConflict();

    final update = scenario.harness.client.patch('/admin/refund-reasons/$id')
      ..bearer(token)
      ..json({
        'label': 'Wrong fit',
        'code': 'wrong_fit',
        'description': null,
      });
    final updated = await update.send();
    updated.assertOk();
    expect(updated.json, containsPair('label', 'Wrong fit'));
    expect(updated.json, containsPair('code', 'wrong_fit'));
    expect(updated.json, containsPair('description', null));

    final remove = scenario.harness.client.delete('/admin/refund-reasons/$id')
      ..bearer(token);
    final removed = await remove.send();
    removed.assertOk();
    expect(removed.json, containsPair('id', id));
    expect(removed.json, containsPair('deleted', true));

    final read = scenario.harness.client.get('/admin/refund-reasons')
      ..bearer(token);
    final listed = await read.send();
    listed.assertOk();
    final reasons = (listed.json! as Map<String, Object?>)['refund_reasons']!
        as List<Object?>;
    expect(reasons.every((row) => (row! as Map<String, Object?>)['id'] != id),
        isTrue);
    final history = await scenario.harness.raw('''
SELECT refund_reason_id FROM refunds
WHERE payment_collection_id = 'pay_detail'
  AND refund_reason_id = '$id'
''');
    expect(history, hasLength(1));
  });

  test('rejects unknown mutation fields before writing', () async {
    final request = scenario.harness.client.post('/admin/refund-reasons')
      ..bearer(await scenario.harness.adminToken())
      ..json({
        'label': 'Wrong size',
        'code': 'wrong_size',
        'metadata': <String, Object?>{},
      });
    (await request.send()).assertStatus(422);
    final rows = await scenario.harness.raw(
      "SELECT count(*) FROM refund_reasons WHERE code = 'wrong_size'",
    );
    expect(rows.single.readIndex<int>(0), 0);
  });
}
