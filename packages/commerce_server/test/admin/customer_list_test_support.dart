import 'support.dart';

/// Inserts registered, guest, and contact-free rows for customer-list tests.
Future<void> seedCustomerList(AdminHarness harness) => harness.raw(r'''
INSERT INTO customers
  (id, email, company_name, first_name, last_name, has_account,
   created_at, updated_at)
VALUES
  ('cus_ada', 'ada@example.com', 'Analytical Engines', 'Ada', 'Lovelace', 1,
   '2026-09-10T10:00:00.000Z', '2026-09-10T10:05:00.000Z'),
  ('cus_contactless', NULL, 'Walk In', NULL, NULL, 0,
   '2026-09-11T10:00:00.000Z', '2026-09-11T10:05:00.000Z'),
  ('cus_guest', 'guest@example.com', NULL, 'Grace', 'Hopper', 0,
   '2026-09-12T10:00:00.000Z', '2026-09-12T10:05:00.000Z'),
  ('cus_deleted', 'deleted@example.com', NULL, 'Deleted', 'Customer', 1,
   '2026-09-13T10:00:00.000Z', '2026-09-13T10:05:00.000Z')
''').then((_) => harness.raw(r'''
UPDATE customers
SET deleted_at = '2026-09-13T11:00:00.000Z'
WHERE id = 'cus_deleted'
'''));
