import 'package:commerce_server/commerce_server.dart';
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
SET metadata = '{"source":"admin","priority":1}'
WHERE id = 'cusgrp_vip'
''');
  });
  tearDown(() => harness.stop());

  test('customer-group detail requires a proven admin bearer', () async {
    (await harness.client.get('/admin/customer-groups/cusgrp_vip').send())
        .assertUnauthorized();
  });

  test('returns the exact detail envelope from a direct SQLx row', () async {
    final decoded = await AdminCustomerGroupDetailRepository(
      harness.database.connection as Executor,
    ).find('cusgrp_vip');
    expect(
      decoded,
      isA<Ok<AdminCustomerGroupDetailResponse?, SqlxError>>(),
      reason: '$decoded',
    );
    final withoutMetadata = await AdminCustomerGroupDetailRepository(
      harness.database.connection as Executor,
    ).find('cusgrp_retail');
    expect(
      (withoutMetadata as Ok<AdminCustomerGroupDetailResponse?, SqlxError>)
          .value
          ?.metadata,
      isNull,
    );
    final request = harness.client.get('/admin/customer-groups/cusgrp_vip')
      ..bearer(await harness.adminToken());

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
    expect(group['metadata'], {'source': 'admin', 'priority': 1});
    final customers = group['customers']! as List<Object?>;
    expect(
      customers.map((value) => (value! as Map<String, Object?>)['id']),
      ['cus_ada', 'cus_guest'],
    );
    expect(DateTime.parse(group['created_at']! as String).isUtc, isTrue);
  });

  test('missing and deleted groups share not found', () async {
    final token = await harness.adminToken();
    for (final id in ['cusgrp_missing', 'cusgrp_retired']) {
      final request = harness.client.get('/admin/customer-groups/$id')
        ..bearer(token);
      (await request.send()).assertNotFound();
    }
  });
}
