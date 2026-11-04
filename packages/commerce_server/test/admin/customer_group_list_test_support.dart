import 'customer_list_test_support.dart';
import 'support.dart';

/// Inserts three active groups, one retired group, and representative members.
Future<void> seedCustomerGroupList(AdminHarness harness) async {
  await seedCustomerList(harness);
  await harness.raw(r'''
INSERT INTO customer_groups
  (id, name, created_at, updated_at)
VALUES
  ('cusgrp_retail', 'Retail',
   '2026-09-10T10:00:00.000Z', '2026-09-10T10:05:00.000Z'),
  ('cusgrp_wholesale', 'Wholesale',
   '2026-09-11T10:00:00.000Z', '2026-09-11T10:05:00.000Z'),
  ('cusgrp_vip', 'VIP',
   '2026-09-12T10:00:00.000Z', '2026-09-12T10:05:00.000Z'),
  ('cusgrp_retired', 'Retired',
   '2026-09-13T10:00:00.000Z', '2026-09-13T10:05:00.000Z')
''');
  await harness.raw(r'''
UPDATE customer_groups
SET deleted_at = '2026-09-13T11:00:00.000Z'
WHERE id = 'cusgrp_retired'
''');
  await harness.raw(r'''
INSERT INTO customer_group_customers
  (id, customer_group_id, customer_id, created_at, updated_at)
VALUES
  ('cgc_vip_ada', 'cusgrp_vip', 'cus_ada',
   '2026-09-12T12:00:00.000Z', '2026-09-12T12:00:00.000Z'),
  ('cgc_vip_guest', 'cusgrp_vip', 'cus_guest',
   '2026-09-12T12:01:00.000Z', '2026-09-12T12:01:00.000Z'),
  ('cgc_vip_deleted', 'cusgrp_vip', 'cus_deleted',
   '2026-09-12T12:02:00.000Z', '2026-09-12T12:02:00.000Z'),
  ('cgc_retail_walkin', 'cusgrp_retail', 'cus_contactless',
   '2026-09-12T12:03:00.000Z', '2026-09-12T12:03:00.000Z')
''');
}
