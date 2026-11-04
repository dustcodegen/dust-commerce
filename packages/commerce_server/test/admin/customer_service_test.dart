import 'package:test/test.dart';

import 'support.dart';

void main() {
  late AdminHarness harness;

  setUp(() async {
    harness = await AdminHarness.start();
    await _submit(harness, subject: 'Damaged cup', email: 'ada@example.com');
    await _submit(harness, subject: 'Sizing', email: 'grace@example.com');
  });
  tearDown(() => harness.stop());

  test('support inbox requires the Admin route guard', () async {
    (await harness.client.get('/admin/customer-service').send())
        .assertUnauthorized();
  });

  test('lists exact merchant fields with search status and paging', () async {
    final token = await harness.adminToken();
    final first = harness.client.get(
      '/admin/customer-service?q=damaged&status=open&order=created_at&limit=1',
    )..bearer(token);

    final response = await first.send();

    response.assertOk();
    final body = response.json! as Map<String, Object?>;
    expect(body, containsPair('count', 1));
    expect(body, containsPair('limit', 1));
    final requests = body['requests']! as List<Object?>;
    final request = requests.single! as Map<String, Object?>;
    expect(request.keys, {
      'id',
      'customer_id',
      'name',
      'email',
      'subject',
      'message',
      'order_reference',
      'status',
      'resolved_at',
      'created_at',
      'updated_at',
    });
    expect(request['subject'], 'Damaged cup');
    expect(request['status'], 'open');
  });

  test('updates lifecycle with database-owned resolution time', () async {
    final token = await harness.adminToken();
    final listed = harness.client
        .get('/admin/customer-service?order=created_at')
      ..bearer(token);
    final list = await listed.send();
    final requests =
        (list.json! as Map<String, Object?>)['requests']! as List<Object?>;
    final id = (requests.first! as Map<String, Object?>)['id']! as String;

    final working = harness.client.post('/admin/customer-service/$id')
      ..bearer(token)
      ..json({'status': 'in_progress'});
    final workingResponse = await working.send();
    workingResponse.assertOk();
    expect(workingResponse.json, containsPair('status', 'in_progress'));
    expect(workingResponse.json, containsPair('resolved_at', null));

    final resolved = harness.client.post('/admin/customer-service/$id')
      ..bearer(token)
      ..json({'status': 'resolved'});
    final resolvedResponse = await resolved.send();
    resolvedResponse.assertOk();
    final body = resolvedResponse.json! as Map<String, Object?>;
    expect(body['status'], 'resolved');
    expect(DateTime.parse(body['resolved_at']! as String).isUtc, isTrue);

    final reopened = harness.client.post('/admin/customer-service/$id')
      ..bearer(token)
      ..json({'status': 'open'});
    final reopenedResponse = await reopened.send();
    reopenedResponse.assertOk();
    expect(reopenedResponse.json, containsPair('resolved_at', null));
  });

  test('rejects unsupported filters, status, fields and missing ids', () async {
    final token = await harness.adminToken();
    for (final query in ['status=closed', 'order=email']) {
      final request = harness.client.get('/admin/customer-service?$query')
        ..bearer(token);
      (await request.send()).assertBadRequest();
    }
    final extra = harness.client.post('/admin/customer-service/id_101')
      ..bearer(token)
      ..json({'status': 'open', 'customer_id': 'cus_attacker'});
    (await extra.send()).assertUnprocessable();
    final invalid = harness.client.post('/admin/customer-service/id_101')
      ..bearer(token)
      ..json({'status': 'closed'});
    (await invalid.send()).assertUnprocessable();
    final missing = harness.client.post('/admin/customer-service/missing')
      ..bearer(token)
      ..json({'status': 'open'});
    (await missing.send()).assertNotFound();
  });
}

Future<void> _submit(
  AdminHarness harness, {
  required String subject,
  required String email,
}) async {
  final request = harness.client.post('/store/customer-service')
    ..json({
      'name': 'Ada',
      'email': email,
      'subject': subject,
      'message': 'Please help with this order.',
      'order_reference': 'ORDER-42',
    });
  (await request.send()).assertCreated();
}
