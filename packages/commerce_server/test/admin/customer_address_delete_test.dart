import 'package:test/test.dart';

import 'customer_address_delete_test_support.dart';
import 'support.dart';

void main() {
  late AdminHarness harness;

  setUp(() async {
    harness = await AdminHarness.start();
    await seedCustomerAddressDeletion(harness);
  });
  tearDown(() => harness.stop());

  test('customer address deletion requires the Admin route guard', () async {
    final response = await harness.client
        .delete('/admin/customers/cus_ada/addresses/addr_home')
        .send();

    response.assertUnauthorized();
  });

  test('deletes one owned address and returns its refreshed parent', () async {
    final request = harness.client
        .delete('/admin/customers/cus_ada/addresses/addr_home')
      ..bearer(await harness.adminToken());

    final response = await request.send();

    response.assertOk();
    final body = response.json! as Map<String, Object?>;
    expect(body.keys, {'id', 'object', 'deleted', 'parent'});
    expect(body, containsPair('id', 'addr_home'));
    expect(body, containsPair('object', 'customer_address'));
    expect(body, containsPair('deleted', true));
    final parent = body['parent']! as Map<String, Object?>;
    final addresses = parent['addresses']! as List<Object?>;
    expect(addresses, hasLength(1));
    expect(addresses.single, containsPair('id', 'addr_work'));
    expect(parent, isNot(contains('metadata')));

    final rows = await harness.raw(r'''
SELECT deleted_at, updated_at FROM customer_addresses WHERE id = 'addr_home'
''');
    final deletedAt = rows.single.readIndexNullable<DateTime>(0)?.toUtc();
    expect(deletedAt, isNotNull);
    expect(deletedAt!.isUtc, isTrue);
    expect(rows.single.readIndex<DateTime>(1).toUtc(), deletedAt);
  });

  test('cannot delete an address through a different parent', () async {
    final request = harness.client
        .delete('/admin/customers/cus_guest/addresses/addr_home')
      ..bearer(await harness.adminToken());

    (await request.send()).assertNotFound();

    final rows = await harness.raw(
      "SELECT deleted_at FROM customer_addresses WHERE id = 'addr_home'",
    );
    expect(rows.single.readIndexNullable<String>(0), isNull);
  });

  test('missing, inactive parent, and repeated deletion return not found',
      () async {
    final token = await harness.adminToken();
    for (final path in [
      '/admin/customers/cus_ada/addresses/addr_missing',
      '/admin/customers/cus_deleted/addresses/addr_home',
    ]) {
      final request = harness.client.delete(path)..bearer(token);
      (await request.send()).assertNotFound();
    }

    final first = harness.client
        .delete('/admin/customers/cus_ada/addresses/addr_home')
      ..bearer(token);
    (await first.send()).assertOk();
    final repeated = harness.client
        .delete('/admin/customers/cus_ada/addresses/addr_home')
      ..bearer(token);
    (await repeated.send()).assertNotFound();
  });
}
