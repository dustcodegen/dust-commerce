import 'package:test/test.dart';

import 'customer_group_list_test_support.dart';
import 'support.dart';

void main() {
  late AdminHarness harness;

  setUp(() async {
    harness = await AdminHarness.start();
    await seedCustomerGroupList(harness);
  });
  tearDown(() => harness.stop());

  test('customer-group membership requires the Admin route guard', () async {
    final request = harness.client.post(
      '/admin/customer-groups/cusgrp_vip/customers',
    )..json({
        'add': ['cus_contactless']
      });

    (await request.send()).assertUnauthorized();
  });

  test('atomically adds and removes memberships then returns fresh detail',
      () async {
    final request = harness.client.post(
      '/admin/customer-groups/cusgrp_vip/customers',
    )
      ..bearer(await harness.adminToken())
      ..json({
        'add': ['cus_contactless'],
        'remove': ['cus_guest'],
      });

    final response = await request.send();

    response.assertOk();
    final body = response.json! as Map<String, Object?>;
    expect(body.keys, {'customer_group'});
    final group = body['customer_group']! as Map<String, Object?>;
    expect(group.keys, {
      'id',
      'name',
      'customers',
      'metadata',
      'created_at',
      'updated_at',
    });
    expect(
      (group['customers']! as List<Object?>)
          .map((item) => (item! as Map<String, Object?>)['id'])
          .toSet(),
      {'cus_ada', 'cus_contactless'},
    );

    final rows = await harness.raw(r'''
SELECT customer_id, created_by, deleted_at, updated_at
FROM customer_group_customers
WHERE customer_group_id = 'cusgrp_vip'
ORDER BY customer_id, created_at
''');
    final added = rows.singleWhere(
      (row) => row.read<String>('customer_id') == 'cus_contactless',
    );
    expect(added.readNullable<String>('created_by'), isNotNull);
    expect(added.readNullable<DateTime>('deleted_at'), isNull);
    final removed = rows.singleWhere(
      (row) => row.read<String>('customer_id') == 'cus_guest',
    );
    final deletedAt = removed.readNullable<DateTime>('deleted_at');
    expect(deletedAt!.isUtc, isTrue);
    expect(removed.read<DateTime>('updated_at'), deletedAt);
  });

  test('existing adds and absent removals are idempotent', () async {
    final request = harness.client.post(
      '/admin/customer-groups/cusgrp_vip/customers',
    )
      ..bearer(await harness.adminToken())
      ..json({
        'add': ['cus_ada'],
        'remove': ['cus_contactless'],
      });

    (await request.send()).assertOk();
    final count = await harness.raw(r'''
SELECT count(*) FROM customer_group_customers
WHERE customer_group_id = 'cusgrp_vip'
  AND customer_id = 'cus_ada' AND deleted_at IS NULL
''');
    expect(count.single.readIndex<int>(0), 1);
  });

  test('rejects empty, duplicate, overlapping, blank, and undeclared input',
      () async {
    final token = await harness.adminToken();
    final bodies = <Map<String, Object?>>[
      {},
      {
        'add': ['cus_ada', 'cus_ada']
      },
      {
        'add': ['cus_ada'],
        'remove': ['cus_ada'],
      },
      {
        'remove': [' ']
      },
      {
        'add': ['cus_contactless'],
        'created_by': 'admin_attacker',
      },
    ];

    for (final body in bodies) {
      final request = harness.client.post(
        '/admin/customer-groups/cusgrp_vip/customers',
      )
        ..bearer(token)
        ..json(body);
      (await request.send()).assertUnprocessable();
    }
  });

  test('missing groups and unavailable customers cannot change membership',
      () async {
    final token = await harness.adminToken();
    for (final groupId in ['cusgrp_missing', 'cusgrp_retired']) {
      final request = harness.client.post(
        '/admin/customer-groups/$groupId/customers',
      )
        ..bearer(token)
        ..json({
          'add': ['cus_contactless']
        });
      (await request.send()).assertNotFound();
    }
    for (final customerId in ['cus_missing', 'cus_deleted']) {
      final request = harness.client.post(
        '/admin/customer-groups/cusgrp_vip/customers',
      )
        ..bearer(token)
        ..json({
          'add': [customerId],
          'remove': ['cus_guest'],
        });
      (await request.send()).assertUnprocessable();
    }
    final active = await harness.raw(r'''
SELECT count(*) FROM customer_group_customers
WHERE customer_group_id = 'cusgrp_vip'
  AND customer_id = 'cus_guest' AND deleted_at IS NULL
''');
    expect(active.single.readIndex<int>(0), 1);
  });

  test('add failure rolls back removals in the same batch', () async {
    await harness.raw(r'''
CREATE OR REPLACE FUNCTION reject_customer_group_membership_add()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  RAISE EXCEPTION 'membership add failed';
END;
$$
''');
    await harness.raw(r'''
CREATE TRIGGER reject_customer_group_membership_add
BEFORE INSERT ON customer_group_customers
FOR EACH ROW EXECUTE FUNCTION reject_customer_group_membership_add()
''');
    final request = harness.client.post(
      '/admin/customer-groups/cusgrp_vip/customers',
    )
      ..bearer(await harness.adminToken())
      ..json({
        'add': ['cus_contactless'],
        'remove': ['cus_guest'],
      });

    (await request.send()).assertStatus(500);
    final active = await harness.raw(r'''
SELECT count(*) FROM customer_group_customers
WHERE customer_group_id = 'cusgrp_vip'
  AND customer_id = 'cus_guest' AND deleted_at IS NULL
''');
    expect(active.single.readIndex<int>(0), 1);
  });
}
