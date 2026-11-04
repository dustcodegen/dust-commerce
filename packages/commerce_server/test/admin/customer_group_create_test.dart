import 'dart:convert';

import 'package:test/test.dart';

import 'support.dart';

void main() {
  late AdminHarness harness;

  setUp(() async => harness = await AdminHarness.start());
  tearDown(() => harness.stop());

  test('customer-group creation requires the Admin route guard', () async {
    final request = harness.client.post('/admin/customer-groups')
      ..json({'name': 'VIP Customers'});

    (await request.send()).assertUnauthorized();
  });

  test('creates the exact Medusa response and stores audit context', () async {
    final request = harness.client.post('/admin/customer-groups')
      ..bearer(await harness.adminToken())
      ..json({
        'name': '  VIP Customers  ',
        'metadata': {
          'source': 'admin',
          'priority': 1,
        },
      });

    final response = await request.send();

    response.assertOk();
    final json = response.json! as Map<String, Object?>;
    expect(json.keys, {'customer_group'});
    final group = json['customer_group']! as Map<String, Object?>;
    expect(group.keys, {
      'id',
      'name',
      'customers',
      'created_at',
      'updated_at',
    });
    expect(group, containsPair('name', 'VIP Customers'));
    expect(group, containsPair('customers', <Object?>[]));
    expect(group, isNot(contains('metadata')));
    expect(DateTime.parse(group['created_at']! as String).isUtc, isTrue);
    expect(group['updated_at'], group['created_at']);

    final rows = await harness.raw('''
SELECT name, created_by, metadata
FROM customer_groups
ORDER BY created_at
LIMIT 1
''');
    expect(rows.single.readIndex<String>(0), 'VIP Customers');
    expect(rows.single.readIndex<String>(1), 'admin_1');
    expect(jsonDecode(rows.single.readIndex<String>(2)), {
      'source': 'admin',
      'priority': 1,
    });
  });

  test('same active name conflicts without overwriting', () async {
    final token = await harness.adminToken();
    final first = harness.client.post('/admin/customer-groups')
      ..bearer(token)
      ..json({'name': 'QA Group'});
    (await first.send()).assertOk();
    final duplicate = harness.client.post('/admin/customer-groups')
      ..bearer(token)
      ..json({'name': 'QA Group'});

    (await duplicate.send()).assertConflict();
    final rows = await harness.raw(r'''
SELECT count(*) FROM customer_groups
WHERE name = 'QA Group' AND deleted_at IS NULL
''');
    expect(rows.single.readIndex<int>(0), 1);
  });

  test('invalid or undeclared input writes no customer group', () async {
    final token = await harness.adminToken();
    final blank = harness.client.post('/admin/customer-groups')
      ..bearer(token)
      ..json({'name': '   '});
    final secret = harness.client.post('/admin/customer-groups')
      ..bearer(token)
      ..json({'name': 'VIP', 'password': 'never accepted'});
    final invalidMetadata = harness.client.post('/admin/customer-groups')
      ..bearer(token)
      ..json({'name': 'VIP', 'metadata': 'not an object'});

    (await blank.send()).assertUnprocessable();
    (await secret.send()).assertUnprocessable();
    (await invalidMetadata.send()).assertUnprocessable();
    final rows = await harness.raw('SELECT count(*) FROM customer_groups');
    expect(rows.single.readIndex<int>(0), 0);
  });
}
