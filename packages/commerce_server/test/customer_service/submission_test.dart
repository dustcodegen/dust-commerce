import 'package:test/test.dart';

import '../account/support.dart';

void main() {
  late AccountTestHarness harness;

  setUp(() async => harness = await AccountTestHarness.start());
  tearDown(() => harness.stop());

  test('guest submission persists normalized content and safe response',
      () async {
    final response = await (harness.client.post('/store/customer-service')
          ..json(_request()))
        .send();

    response.assertCreated();
    expect(response.json, containsPair('id', 'id_1'));
    final body = response.json! as Map<String, Object?>;
    expect(body.keys, {'id', 'created_at'});
    expect(DateTime.parse(body['created_at']! as String).isUtc, isTrue);

    final rows = await harness.raw(
      'SELECT customer_id, name, email, subject, message, order_reference, '
      "status FROM customer_service_requests WHERE id = 'id_1'",
    );
    final request = rows.single;
    expect(request.readNullable<String>('customer_id'), isNull);
    expect(request.read<String>('name'), 'Ada Lovelace');
    expect(request.read<String>('email'), 'ada@example.com');
    expect(request.read<String>('subject'), 'Order question');
    expect(request.read<String>('message'), 'Where is my order?');
    expect(request.read<String>('order_reference'), 'ORDER-42');
    expect(request.read<String>('status'), 'open');
  });

  test('signed-in submission records only proven customer ownership', () async {
    final token = await harness.registerAndSignIn();
    final response = await (harness.client.post('/store/customer-service')
          ..bearer(token)
          ..json(_request()))
        .send();

    response.assertCreated();
    final id = (response.json! as Map<String, Object?>)['id']! as String;
    final rows = await harness.raw(
      r'SELECT customer_id FROM customer_service_requests WHERE id = $1',
      [id],
    );
    expect(rows.single.read<String>('customer_id'), isNotEmpty);
  });

  test('rejects invalid auth, invalid content and unknown fields', () async {
    final invalidAuth = harness.client.post('/store/customer-service')
      ..bearer('not-valid')
      ..json(_request());
    (await invalidAuth.send()).assertUnauthorized();

    final invalid = harness.client.post('/store/customer-service')
      ..json({..._request(), 'email': 'invalid'});
    (await invalid.send()).assertStatus(422);

    final unknown = harness.client.post('/store/customer-service')
      ..json({..._request(), 'internal_status': 'resolved'});
    (await unknown.send()).assertUnprocessable();
  });
}

Map<String, Object?> _request() => {
      'name': '  Ada Lovelace ',
      'email': ' ADA@Example.COM ',
      'subject': ' Order question ',
      'message': ' Where is my order? ',
      'order_reference': 'ORDER-42',
    };
