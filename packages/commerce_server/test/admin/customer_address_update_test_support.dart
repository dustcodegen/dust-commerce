import 'customer_list_test_support.dart';
import 'support.dart';

/// Seeds active, deleted, and foreign-parent address update fixtures.
Future<void> seedCustomerAddressUpdate(AdminHarness harness) async {
  await seedCustomerList(harness);
  await harness.raw(r'''
INSERT INTO customer_addresses (
  id, customer_id, address_name, first_name, address_1, city, country_code,
  is_default_shipping, is_default_billing, created_at, updated_at, deleted_at
)
VALUES
  ('addr_home', 'cus_ada', 'Home', 'Ada', '12 St James Square', 'London', 'gb',
   1, 0, '2026-09-10T10:00:00.000Z', '2026-09-10T10:00:00.000Z', NULL),
  ('addr_work', 'cus_ada', 'Work', 'Ada', '1 Engine Way', 'London', 'gb',
   0, 1, '2026-09-10T11:00:00.000Z', '2026-09-10T11:00:00.000Z', NULL),
  ('addr_guest', 'cus_guest', 'Home', 'Grace', '2 Compiler Road', NULL, 'us',
   1, 1, '2026-09-12T10:00:00.000Z', '2026-09-12T10:00:00.000Z', NULL),
  ('addr_deleted', 'cus_ada', 'Old', NULL, '3 Old Road', NULL, 'gb',
   0, 0, '2026-09-09T10:00:00.000Z', '2026-09-09T10:00:00.000Z',
   '2026-09-11T10:00:00.000Z'),
  ('addr_deleted_parent', 'cus_deleted', 'Old', NULL, '4 Old Road', NULL, 'gb',
   0, 0, '2026-09-09T10:00:00.000Z', '2026-09-09T10:00:00.000Z', NULL)
''');
}
