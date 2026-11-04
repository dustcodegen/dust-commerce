import 'package:commerce_server/commerce_server.dart';

import 'customer_list_test_support.dart';
import 'support.dart';

/// Bearers seeded for account-removal integration assertions.
final class CustomerDeleteTokens {
  /// Creates the two independent actor capabilities.
  const CustomerDeleteTokens({required this.customer, required this.shared});

  /// Token owned only by the registered customer identity.
  final String customer;

  /// Token retained by an identity that also owns an Admin actor.
  final String shared;
}

/// Seeds guest, registered, shared-actor and broken account boundaries.
Future<CustomerDeleteTokens> seedCustomerDeletion(AdminHarness harness) async {
  await seedCustomerList(harness);
  await harness.raw(r'''
INSERT INTO customers (id, email, first_name, last_name, has_account)
VALUES
  ('cus_shared', 'shared@example.com', 'Shared', 'Actor', 1),
  ('cus_broken', 'broken@example.com', 'Broken', 'Account', 1)
''');
  await harness.raw(r'''
INSERT INTO customer_addresses
  (id, customer_id, first_name, last_name, address_1, city, postal_code,
   country_code)
VALUES
  ('addr_guest', 'cus_guest', 'Grace', 'Hopper', '1 Navy Way', 'Arlington',
   '22202', 'us'),
  ('addr_ada', 'cus_ada', 'Ada', 'Lovelace', '12 St James Square', 'London',
   'SW1Y 4LB', 'gb'),
  ('addr_shared', 'cus_shared', 'Shared', 'Actor', '1 Admin Way', 'London',
   'SW1A 1AA', 'gb')
''');
  await harness.raw(r'''
INSERT INTO admin_users (id, email, first_name, last_name)
VALUES ('admin_shared', 'shared@example.com', 'Shared', 'Admin')
''');
  await harness.raw(r'''
INSERT INTO auth_identity (id, app_metadata)
VALUES
  ('auth_customer', '{"customer_id":"cus_ada"}'),
  ('auth_shared',
   '{"customer_id":"cus_shared","admin_user_id":"admin_shared"}')
''');
  await harness.raw(r'''
INSERT INTO provider_identity
  (id, entity_id, provider, auth_identity_id, provider_metadata)
VALUES
  ('provider_customer', 'ada@example.com', 'emailpass', 'auth_customer', '{}'),
  ('provider_shared', 'shared@example.com', 'emailpass', 'auth_shared', '{}')
''');
  const customerToken = 'customer-delete-session';
  const sharedToken = 'shared-actor-session';
  await harness.raw('''
INSERT INTO auth_tokens (token_hash, auth_identity_id, expires_at)
VALUES
  ('${await Tokens.fingerprint(customerToken)}', 'auth_customer',
   '2100-01-08T12:00:00.000Z'),
  ('${await Tokens.fingerprint(sharedToken)}', 'auth_shared',
   '2100-01-08T12:00:00.000Z')
''');
  await harness.raw(r'''
INSERT INTO email_verifications
  (auth_identity_id, token_hash, expires_at)
VALUES
  ('auth_customer',
   'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
   '2100-01-08T12:00:00.000Z')
''');
  await harness.raw(r'''
INSERT INTO carts (id, region_id, customer_id, email, completed_at)
VALUES ('cart_guest_history', 'reg_eu', 'cus_guest', 'guest@example.com',
        '2026-09-14T01:00:00.000Z')
''');
  await harness.raw(r'''
INSERT INTO orders
  (id, display_id, cart_id, region_id, customer_id, email, currency_code,
   subtotal, tax, total, status, payment_status, placed_at)
VALUES
  ('ord_guest_history', 9901, 'cart_guest_history', 'reg_eu', 'cus_guest',
   'guest@example.com', 'eur', 2500, 0, 2500, 'completed', 'captured',
   '2026-09-14T01:00:00.000Z')
''');
  return const CustomerDeleteTokens(
    customer: customerToken,
    shared: sharedToken,
  );
}
