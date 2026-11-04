import 'package:commerce_server/commerce_server.dart';
import 'package:commerce_server/src/features/admin_customer/detail_model.dart';
import 'package:commerce_server/src/features/admin_customer/detail_repository.dart';
import 'package:test/test.dart';

import 'customer_list_test_support.dart';
import 'support.dart';

void main() {
  late AdminHarness harness;

  setUp(() async {
    harness = await AdminHarness.start();
    await seedCustomerList(harness);
    await _seedDetail(harness);
  });
  tearDown(() => harness.stop());

  test('customer detail requires a proven admin bearer', () async {
    (await harness.client.get('/admin/customers/cus_ada').send())
        .assertUnauthorized();
  });

  test('customer detail exposes profile and active address allowlists',
      () async {
    final decoded = await AdminCustomerDetailRepository(
      harness.database.connection as Executor,
    ).find('cus_ada');
    expect(
      decoded,
      isA<Ok<AdminCustomerDetailResponse?, SqlxError>>(),
      reason: '$decoded',
    );
    final request = harness.client.get('/admin/customers/cus_ada')
      ..bearer(await harness.adminToken());
    final response = await request.send();

    response.assertOk();
    final customer = response.json! as Map<String, Object?>;
    expect(customer.keys, {
      'addresses',
      'company_name',
      'created_at',
      'email',
      'first_name',
      'has_account',
      'id',
      'last_name',
      'phone',
      'updated_at',
    });
    expect(customer, containsPair('company_name', 'Analytical Engines'));
    expect(customer, containsPair('phone', '+44 20 0000 0000'));
    expect(customer, isNot(contains('metadata')));
    final addresses = customer['addresses']! as List<Object?>;
    expect(addresses, hasLength(1));
    expect((addresses.single! as Map<String, Object?>).keys, {
      'address_1',
      'address_2',
      'address_name',
      'city',
      'company',
      'country_code',
      'first_name',
      'id',
      'is_default_billing',
      'is_default_shipping',
      'last_name',
      'phone',
      'postal_code',
      'province',
    });
  });

  test('missing and deleted customers share not found', () async {
    final token = await harness.adminToken();
    for (final id in ['cus_missing', 'cus_deleted']) {
      final request = harness.client.get('/admin/customers/$id')..bearer(token);
      (await request.send()).assertNotFound();
    }
  });
}

Future<void> _seedDetail(AdminHarness harness) async {
  await harness.raw(
    "UPDATE customers SET phone = '+44 20 0000 0000' WHERE id = 'cus_ada'",
  );
  await harness.raw(r'''
INSERT INTO customer_addresses
  (id, customer_id, first_name, last_name, company, phone, address_1,
   address_2, city, province, postal_code, country_code,
   is_default_shipping, is_default_billing)
VALUES
  ('addr_active', 'cus_ada', 'Ada', 'Lovelace', NULL, '+44 20 0000 0000',
   '12 St James Square', NULL, 'London', NULL, 'SW1Y 4LB', 'gb', 1, 1),
  ('addr_deleted', 'cus_ada', 'Ada', 'Lovelace', NULL, NULL,
   'Old Street', NULL, 'London', NULL, 'EC1V 9NR', 'gb', 0, 0)
''');
  await harness.raw(r'''
UPDATE customer_addresses
SET deleted_at = '2026-09-13T11:00:00.000Z'
WHERE id = 'addr_deleted'
''');
}
