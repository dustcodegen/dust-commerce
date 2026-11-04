import 'package:test/test.dart';

import 'customer_list_test_support.dart';
import 'support.dart';

void main() {
  late AdminHarness harness;

  setUp(() async {
    harness = await AdminHarness.start();
    await seedCustomerList(harness);
    await harness.raw(r'''
INSERT INTO customer_addresses
  (id, customer_id, first_name, last_name, address_1, city, postal_code,
   country_code)
VALUES
  ('addr_guest', 'cus_guest', 'Grace', 'Hopper', '1 Navy Way', 'Arlington',
   '22202', 'us')
''');
    await harness.raw(r'''
UPDATE customers SET email = 'other@example.com'
WHERE id = 'cus_contactless'
''');
  });
  tearDown(() => harness.stop());

  test('customer update requires the Admin route guard', () async {
    final response = await (harness.client.patch('/admin/customers/cus_guest')
          ..json(_body()))
        .send();

    response.assertUnauthorized();
  });

  test('updates guest email and returns preserved addresses', () async {
    final request = harness.client.patch('/admin/customers/cus_guest')
      ..bearer(await harness.adminToken())
      ..json(_body(email: '  NEW.GUEST@Example.com '));

    final response = await request.send();

    response.assertOk();
    final customer = response.json! as Map<String, Object?>;
    expect(customer, containsPair('email', 'new.guest@example.com'));
    expect(customer, containsPair('company_name', 'NASA'));
    expect(customer['addresses'], hasLength(1));
    expect(customer, isNot(contains('metadata')));
    expect(
      DateTime.parse(customer['updated_at']! as String).isUtc,
      isTrue,
    );
  });

  test('registered profile updates without changing owned email', () async {
    final request = harness.client.patch('/admin/customers/cus_ada')
      ..bearer(await harness.adminToken())
      ..json(_body(email: null, company: null, firstName: 'Augusta'));

    final response = await request.send();

    response.assertOk();
    final customer = response.json! as Map<String, Object?>;
    expect(customer, containsPair('email', 'ada@example.com'));
    expect(customer, containsPair('first_name', 'Augusta'));
    expect(customer, containsPair('company_name', null));
    expect(customer, containsPair('has_account', true));
  });

  test('registered email mutation and guest collision preserve rows', () async {
    final token = await harness.adminToken();
    final registered = harness.client.patch('/admin/customers/cus_ada')
      ..bearer(token)
      ..json(_body(email: 'attacker@example.com'));
    final collision = harness.client.patch('/admin/customers/cus_guest')
      ..bearer(token)
      ..json(_body(email: 'OTHER@EXAMPLE.COM'));

    (await registered.send()).assertConflict();
    (await collision.send()).assertConflict();
    final rows = await harness.raw(r'''
SELECT id, email, first_name FROM customers
WHERE id IN ('cus_ada', 'cus_guest') ORDER BY id
''');
    expect(rows[0].read<String>('email'), 'ada@example.com');
    expect(rows[0].read<String>('first_name'), 'Ada');
    expect(rows[1].read<String>('email'), 'guest@example.com');
    expect(rows[1].read<String>('first_name'), 'Grace');
  });

  test('unknown input and unavailable customers never mutate', () async {
    final token = await harness.adminToken();
    final secret = harness.client.patch('/admin/customers/cus_guest')
      ..bearer(token)
      ..json({..._body(), 'password': 'never-accepted'});
    (await secret.send()).assertUnprocessable();

    for (final id in ['cus_missing', 'cus_deleted']) {
      final request = harness.client.patch('/admin/customers/$id')
        ..bearer(token)
        ..json(_body());
      (await request.send()).assertNotFound();
    }
  });
}

Map<String, Object?> _body({
  String? email = 'guest.updated@example.com',
  String? company = 'NASA',
  String? firstName = 'Katherine',
}) =>
    {
      'email': email,
      'company_name': company,
      'first_name': firstName,
      'last_name': 'Johnson',
      'phone': '+1 202 555 0147',
    };
