import 'customer_list_test_support.dart';
import 'support.dart';

/// Seeds two Ada addresses and one address owned by another customer.
Future<void> seedCustomerAddressDeletion(AdminHarness harness) async {
  await seedCustomerList(harness);
  await harness.raw(r'''
INSERT INTO customer_addresses (
  id, customer_id, address_name, address_1, country_code,
  is_default_shipping, is_default_billing
)
VALUES
  ('addr_home', 'cus_ada', 'Home', '12 St James Square', 'gb', 1, 0),
  ('addr_work', 'cus_ada', 'Work', '1 Engine Way', 'gb', 0, 0),
  ('addr_guest', 'cus_guest', 'Home', '2 Compiler Road', 'us', 1, 1)
''');
}
