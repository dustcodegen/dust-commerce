import 'package:test/test.dart';

import 'customer_address_update_test_support.dart';
import 'support.dart';

void main() {
  late AdminHarness harness;

  setUp(() async {
    harness = await AdminHarness.start();
    await seedCustomerAddressUpdate(harness);
  });
  tearDown(() => harness.stop());

  test('customer address update requires the Admin route guard', () async {
    final response = await (harness.client.post(_path('cus_ada', 'addr_home'))
          ..json({'city': 'Oxford'}))
        .send();

    response.assertUnauthorized();
  });

  test('patches present fields, clears null, and preserves omitted fields',
      () async {
    final request = harness.client.post(_path('cus_ada', 'addr_home'))
      ..bearer(await harness.adminToken())
      ..json({
        'address_name': ' Primary ',
        'city': null,
        'country_code': 'US',
      });

    final response = await request.send();

    response.assertOk();
    final customer = response.json! as Map<String, Object?>;
    final addresses = customer['addresses']! as List<Object?>;
    final home = addresses.cast<Map<String, Object?>>().firstWhere(
          (address) => address['id'] == 'addr_home',
        );
    expect(home, containsPair('address_name', 'Primary'));
    expect(home, containsPair('city', null));
    expect(home, containsPair('country_code', 'us'));
    expect(home, containsPair('address_1', '12 St James Square'));
    expect(home, containsPair('first_name', 'Ada'));
    expect(home, isNot(contains('metadata')));

    final rows = await harness.raw(r'''
SELECT created_at, updated_at FROM customer_addresses WHERE id = 'addr_home'
''');
    final createdAt = rows.single.readIndex<DateTime>(0).toUtc();
    expect(createdAt, DateTime.utc(2026, 9, 10, 10));
    final updatedAt = rows.single.readIndex<DateTime>(1).toUtc();
    expect(updatedAt, isNot(createdAt));
    expect(updatedAt.isUtc, isTrue);
  });

  test('selecting a new default atomically clears the previous default',
      () async {
    final request = harness.client.post(_path('cus_ada', 'addr_work'))
      ..bearer(await harness.adminToken())
      ..json({'is_default_shipping': true});

    (await request.send()).assertOk();

    final defaults = await harness.raw(r'''
SELECT id FROM customer_addresses
WHERE customer_id = 'cus_ada' AND is_default_shipping = 1
  AND deleted_at IS NULL
''');
    expect(defaults, hasLength(1));
    expect(defaults.single.readIndex<String>(0), 'addr_work');
  });

  test('foreign, missing, deleted, and inactive-parent addresses stay hidden',
      () async {
    final token = await harness.adminToken();
    for (final target in [
      ('cus_guest', 'addr_home'),
      ('cus_ada', 'addr_missing'),
      ('cus_ada', 'addr_deleted'),
      ('cus_deleted', 'addr_deleted_parent'),
    ]) {
      final request = harness.client.post(_path(target.$1, target.$2))
        ..bearer(token)
        ..json({'city': 'Changed'});
      (await request.send()).assertNotFound();
    }

    final rows = await harness.raw(r'''
SELECT count(*) FROM customer_addresses WHERE city = 'Changed'
''');
    expect(rows.single.readIndex<int>(0), 0);
  });

  test('empty, unknown, invalid, and required-null patches are rejected',
      () async {
    final token = await harness.adminToken();
    for (final body in <Map<String, Object?>>[
      {},
      {'customer_id': 'cus_guest'},
      {'is_default_shipping': 'yes'},
      {'address_1': null},
      {'country_code': null},
    ]) {
      final request = harness.client.post(_path('cus_ada', 'addr_home'))
        ..bearer(token)
        ..json(body);
      (await request.send()).assertUnprocessable();
    }
  });

  test('storage failure rolls back default and field changes', () async {
    await harness.raw(r'''
CREATE OR REPLACE FUNCTION reject_address_update()
RETURNS TRIGGER
LANGUAGE PLPGSQL
AS $$
BEGIN
  IF NEW.id = 'addr_work' THEN
    RAISE EXCEPTION 'injected failure';
  END IF;
  RETURN NEW;
END;
$$;
''');
    await harness.raw(r'''
CREATE TRIGGER reject_address_update
BEFORE UPDATE ON customer_addresses
FOR EACH ROW EXECUTE FUNCTION reject_address_update();
''');
    final request = harness.client.post(_path('cus_ada', 'addr_work'))
      ..bearer(await harness.adminToken())
      ..json({'address_name': 'Rejected', 'is_default_shipping': true});

    (await request.send()).assertStatus(500);

    final rows = await harness.raw(r'''
SELECT address_name, is_default_shipping FROM customer_addresses
WHERE id = 'addr_work'
''');
    expect(rows.single.readIndex<String>(0), 'Work');
    expect(rows.single.readIndex<int>(1), 0);
    final currentDefault = await harness.raw(r'''
SELECT id FROM customer_addresses WHERE customer_id = 'cus_ada'
  AND is_default_shipping = 1 AND deleted_at IS NULL
''');
    expect(currentDefault.single.readIndex<String>(0), 'addr_home');
  });
}

String _path(String customerId, String addressId) =>
    '/admin/customers/$customerId/addresses/$addressId';
