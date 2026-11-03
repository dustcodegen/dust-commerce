import 'package:test/test.dart';

import 'customer_list_test_support.dart';
import 'support.dart';

void main() {
  late AdminHarness harness;

  setUp(() async {
    harness = await AdminHarness.start();
    await seedCustomerList(harness);
  });
  tearDown(() => harness.stop());

  test('customer address creation requires the Admin route guard', () async {
    final response =
        await (harness.client.post('/admin/customers/cus_ada/addresses')
              ..json(_body()))
            .send();

    response.assertUnauthorized();
  });

  test('creates a source-shaped address and returns refreshed customer',
      () async {
    final request = harness.client.post('/admin/customers/cus_ada/addresses')
      ..bearer(await harness.adminToken())
      ..json(_body());

    final response = await request.send();

    response.assertOk();
    final customer = response.json! as Map<String, Object?>;
    final addresses = customer['addresses']! as List<Object?>;
    expect(addresses, hasLength(1));
    expect(addresses.single, containsPair('address_name', 'Home'));
    expect(addresses.single, containsPair('address_1', '12 St James Square'));
    expect(addresses.single, containsPair('city', null));
    expect(addresses.single, isNot(contains('metadata')));
    final timestamps = await harness.raw('''
SELECT created_at, updated_at FROM customer_addresses
WHERE customer_id = 'cus_ada' AND deleted_at IS NULL
''');
    final createdAt = timestamps.single.readIndex<DateTime>(0).toUtc();
    expect(createdAt.isUtc, isTrue);
    expect(timestamps.single.readIndex<DateTime>(1).toUtc(), createdAt);
  });

  test('selecting a new default atomically clears the previous default',
      () async {
    final token = await harness.adminToken();
    for (final name in ['Home', 'Work']) {
      final request = harness.client.post('/admin/customers/cus_ada/addresses')
        ..bearer(token)
        ..json(_body(name: name, defaultShipping: true));
      (await request.send()).assertOk();
    }

    final defaults = await harness.raw('''
SELECT address_name FROM customer_addresses
WHERE customer_id = 'cus_ada' AND is_default_shipping = 1
  AND deleted_at IS NULL
''');
    expect(defaults, hasLength(1));
    expect(defaults.single.readIndex<String>(0), 'Work');
  });

  test('missing or deleted customer writes no address', () async {
    final token = await harness.adminToken();
    for (final id in ['cus_missing', 'cus_deleted']) {
      final request = harness.client.post('/admin/customers/$id/addresses')
        ..bearer(token)
        ..json(_body());
      (await request.send()).assertNotFound();
    }
    final rows = await harness.raw('SELECT count(*) FROM customer_addresses');
    expect(rows.single.readIndex<int>(0), 0);
  });

  test('invalid or unknown address input writes nothing', () async {
    final token = await harness.adminToken();
    final invalid = harness.client.post('/admin/customers/cus_ada/addresses')
      ..bearer(token)
      ..json(_body(country: 'Great Britain'));
    final unknown = harness.client.post('/admin/customers/cus_ada/addresses')
      ..bearer(token)
      ..json({..._body(), 'customer_id': 'cus_guest'});

    (await invalid.send()).assertUnprocessable();
    (await unknown.send()).assertUnprocessable();
    final rows = await harness.raw('SELECT count(*) FROM customer_addresses');
    expect(rows.single.readIndex<int>(0), 0);
  });
}

Map<String, Object?> _body({
  String name = 'Home',
  String country = 'GB',
  bool defaultShipping = false,
}) =>
    {
      'address_name': name,
      'address_1': ' 12 St James Square ',
      'address_2': '',
      'country_code': country,
      'city': '',
      'postal_code': null,
      'province': null,
      'company': null,
      'phone': null,
      'is_default_shipping': defaultShipping,
      'is_default_billing': false,
    };
