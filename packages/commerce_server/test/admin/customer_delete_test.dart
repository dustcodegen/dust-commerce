import 'dart:convert';

import 'package:test/test.dart';

import 'customer_delete_test_support.dart';
import 'support.dart';

void main() {
  late AdminHarness harness;
  late CustomerDeleteTokens tokens;

  setUp(() async {
    harness = await AdminHarness.start(seedStore: true);
    tokens = await seedCustomerDeletion(harness);
  });
  tearDown(() => harness.stop());

  test('customer deletion requires the Admin route guard', () async {
    final response =
        await harness.client.delete('/admin/customers/cus_guest').send();

    response.assertUnauthorized();
  });

  test('deletes a guest graph while retaining order history', () async {
    final token = await harness.adminToken();
    final response = await (harness.client.delete('/admin/customers/cus_guest')
          ..bearer(token))
        .send();

    response
      ..assertOk()
      ..assertJson({
        'id': 'cus_guest',
        'object': 'customer',
        'deleted': true,
      });
    final rows = await harness.raw(r'''
SELECT customer.deleted_at, address.deleted_at, order_row.customer_id
FROM customers customer
JOIN customer_addresses address ON address.customer_id = customer.id
JOIN orders order_row ON order_row.customer_id = customer.id
WHERE customer.id = 'cus_guest'
''');
    expect(rows.single.readIndex<DateTime?>(0), isNotNull);
    expect(rows.single.readIndex<DateTime?>(1), isNotNull);
    expect(rows.single.readIndex<String>(2), 'cus_guest');

    final repeated = harness.client.delete('/admin/customers/cus_guest')
      ..bearer(token);
    (await repeated.send()).assertNotFound();
  });

  test('removes a registered customer identity and every capability', () async {
    final request = harness.client.delete('/admin/customers/cus_ada')
      ..bearer(await harness.adminToken());
    (await request.send()).assertOk();

    final rows = await harness.raw(r'''
SELECT customer.deleted_at, address.deleted_at, auth.deleted_at,
       provider.deleted_at,
       (SELECT count(*) FROM auth_tokens WHERE auth_identity_id = auth.id),
       (SELECT count(*) FROM email_verifications
        WHERE auth_identity_id = auth.id)
FROM customers customer
JOIN customer_addresses address ON address.customer_id = customer.id
JOIN auth_identity auth
  ON json_extract(auth.app_metadata, '$.customer_id') = customer.id
JOIN provider_identity provider ON provider.auth_identity_id = auth.id
WHERE customer.id = 'cus_ada'
''');
    expect(rows.single.readIndex<DateTime?>(0), isNotNull);
    expect(rows.single.readIndex<DateTime?>(1), isNotNull);
    expect(rows.single.readIndex<DateTime?>(2), isNotNull);
    expect(rows.single.readIndex<DateTime?>(3), isNotNull);
    expect(rows.single.readIndex<int>(4), 0);
    expect(rows.single.readIndex<int>(5), 0);
    final me = harness.client.get('/store/customers/me')
      ..bearer(tokens.customer);
    (await me.send()).assertUnauthorized();
  });

  test('detaches only the customer actor from a shared identity', () async {
    final request = harness.client.delete('/admin/customers/cus_shared')
      ..bearer(await harness.adminToken());
    (await request.send()).assertOk();

    final rows = await harness.raw(r'''
SELECT app_metadata, deleted_at,
       (SELECT deleted_at FROM provider_identity
        WHERE auth_identity_id = auth_identity.id),
       (SELECT count(*) FROM auth_tokens
        WHERE auth_identity_id = auth_identity.id)
FROM auth_identity WHERE id = 'auth_shared'
''');
    final metadata =
        jsonDecode(rows.single.readIndex<String>(0)) as Map<String, Object?>;
    expect(metadata, {'admin_user_id': 'admin_shared'});
    expect(rows.single.readIndexNullable<String>(1), isNull);
    expect(rows.single.readIndexNullable<String>(2), isNull);
    expect(rows.single.readIndex<int>(3), 1);
    final admin = harness.client.get('/admin/customers')..bearer(tokens.shared);
    (await admin.send()).assertOk();
    final store = harness.client.get('/store/customers/me')
      ..bearer(tokens.shared);
    (await store.send()).assertUnauthorized();
  });

  test('missing identity rolls back registered customer deletion', () async {
    final request = harness.client.delete('/admin/customers/cus_broken')
      ..bearer(await harness.adminToken());
    final response = await request.send();

    response.assertStatus(500);
    final rows = await harness.raw(r'''
SELECT deleted_at FROM customers WHERE id = 'cus_broken'
''');
    expect(rows.single.readIndexNullable<String>(0), isNull);
  });
}
