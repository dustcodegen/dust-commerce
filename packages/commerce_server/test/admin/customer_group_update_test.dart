import 'package:test/test.dart';

import 'customer_group_list_test_support.dart';
import 'support.dart';

void main() {
  late AdminHarness harness;

  setUp(() async {
    harness = await AdminHarness.start();
    await seedCustomerGroupList(harness);
    await harness.raw(r'''
UPDATE customer_groups
SET metadata = '{"source":"admin","priority":1}',
    updated_at = '2026-09-12T10:05:00.000Z'
WHERE id = 'cusgrp_vip'
''');
  });
  tearDown(() => harness.stop());

  test('customer-group update requires the Admin route guard', () async {
    final request = harness.client.post('/admin/customer-groups/cusgrp_vip')
      ..json({'name': 'VIP Customers'});

    (await request.send()).assertUnauthorized();
  });

  test('renames the group and returns refreshed direct SQLx detail', () async {
    final request = harness.client.post('/admin/customer-groups/cusgrp_vip')
      ..bearer(await harness.adminToken())
      ..json({'name': '  VIP Customers  '});

    final response = await request.send();

    response.assertOk();
    final json = response.json! as Map<String, Object?>;
    expect(json.keys, {'customer_group'});
    final group = json['customer_group']! as Map<String, Object?>;
    expect(group.keys, {
      'id',
      'name',
      'customers',
      'metadata',
      'created_at',
      'updated_at',
    });
    expect(group['id'], 'cusgrp_vip');
    expect(group['name'], 'VIP Customers');
    expect(group['metadata'], {'source': 'admin', 'priority': 1});
    expect(
      (group['customers']! as List<Object?>)
          .map((value) => (value! as Map<String, Object?>)['id']),
      ['cus_ada', 'cus_guest'],
    );
    expect(group['created_at'], '2026-09-12T10:00:00.000Z');
    expect(
      DateTime.parse(group['updated_at']! as String)
          .isAfter(DateTime.utc(2026, 9, 12, 10, 5)),
      isTrue,
    );

    final stored = await harness.raw(r'''
SELECT name, metadata, created_at FROM customer_groups
WHERE id = 'cusgrp_vip'
''');
    expect(stored.single.read<String>('name'), 'VIP Customers');
    expect(stored.single.read<String>('metadata'),
        '{"source":"admin","priority":1}');
    expect(stored.single.read<DateTime>('created_at'),
        DateTime.utc(2026, 9, 12, 10));
  });

  test('invalid or undeclared input preserves the group', () async {
    final token = await harness.adminToken();
    final blank = harness.client.post('/admin/customer-groups/cusgrp_vip')
      ..bearer(token)
      ..json({'name': '   '});
    final secret = harness.client.post('/admin/customer-groups/cusgrp_vip')
      ..bearer(token)
      ..json({'name': 'VIP Customers', 'created_by': 'admin_attacker'});

    (await blank.send()).assertUnprocessable();
    (await secret.send()).assertUnprocessable();
    final stored = await harness.raw(r'''
SELECT name FROM customer_groups WHERE id = 'cusgrp_vip'
''');
    expect(stored.single.read<String>('name'), 'VIP');
  });

  test('missing and deleted groups share not found', () async {
    final token = await harness.adminToken();
    for (final id in ['cusgrp_missing', 'cusgrp_retired']) {
      final request = harness.client.post('/admin/customer-groups/$id')
        ..bearer(token)
        ..json({'name': 'Unavailable'});
      (await request.send()).assertNotFound();
    }
    final retired = await harness.raw(r'''
SELECT name FROM customer_groups WHERE id = 'cusgrp_retired'
''');
    expect(retired.single.read<String>('name'), 'Retired');
  });
}
