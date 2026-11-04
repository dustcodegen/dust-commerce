import 'package:test/test.dart';

import 'customer_list_test_support.dart';
import 'support.dart';

void main() {
  late AdminHarness harness;

  setUp(() async => harness = await AdminHarness.start());
  tearDown(() => harness.stop());

  test('customer creation requires the Admin route guard', () async {
    final response =
        await (harness.client.post('/admin/customers')..json(_body())).send();

    response.assertUnauthorized();
  });

  test('creates one direct guest profile without credentials', () async {
    final token = await harness.adminToken();
    final response = await (harness.client.post('/admin/customers')
          ..bearer(token)
          ..json(_body(email: '  NEW.CUSTOMER@Example.com ')))
        .send();

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
    expect(customer, containsPair('email', 'new.customer@example.com'));
    expect(customer, containsPair('has_account', false));
    expect(customer, containsPair('addresses', <Object?>[]));
    expect(customer, isNot(contains('password')));
    expect(DateTime.parse(customer['created_at']! as String).isUtc, isTrue);
    expect(customer['updated_at'], customer['created_at']);

    final credentials = await harness.raw('''
SELECT count(*) FROM provider_identity
WHERE entity_id = 'new.customer@example.com' AND provider = 'emailpass'
''');
    expect(credentials.single.readIndex<int>(0), 0);
  });

  test('same active guest email conflicts without overwriting', () async {
    final token = await harness.adminToken();
    final first = harness.client.post('/admin/customers')
      ..bearer(token)
      ..json(_body(firstName: 'First'));
    (await first.send()).assertOk();
    final duplicate = harness.client.post('/admin/customers')
      ..bearer(token)
      ..json(_body(firstName: 'Replacement'));

    (await duplicate.send()).assertConflict();
    final rows = await harness.raw('''
SELECT first_name FROM customers
WHERE email = 'customer@example.com' AND has_account = 0
  AND deleted_at IS NULL
''');
    expect(rows, hasLength(1));
    expect(rows.single.readIndex<String>(0), 'First');
  });

  test('registered ownership survives a same-email guest profile', () async {
    await seedCustomerList(harness);
    final token = await harness.adminToken();
    final request = harness.client.post('/admin/customers')
      ..bearer(token)
      ..json(_body(email: 'ADA@EXAMPLE.COM'));

    final response = await request.send();
    response.assertOk();
    expect(
      (response.json! as Map<String, Object?>)['has_account'],
      isFalse,
    );
    final rows = await harness.raw('''
SELECT has_account FROM customers
WHERE email = 'ada@example.com' AND deleted_at IS NULL
ORDER BY has_account
''');
    expect(rows.map((row) => row.readIndex<int>(0)), [0, 1]);
  });

  test('invalid or secret-shaped input writes no customer', () async {
    final token = await harness.adminToken();
    final invalid = harness.client.post('/admin/customers')
      ..bearer(token)
      ..json(_body(email: 'not-an-email'));
    final secret = harness.client.post('/admin/customers')
      ..bearer(token)
      ..json({..._body(), 'password': 'should-never-be-accepted'});

    (await invalid.send()).assertUnprocessable();
    (await secret.send()).assertUnprocessable();
    final rows = await harness.raw('''
SELECT count(*) FROM customers
WHERE email IN ('not-an-email', 'customer@example.com')
''');
    expect(rows.single.readIndex<int>(0), 0);
  });
}

Map<String, Object?> _body({
  String email = 'customer@example.com',
  String firstName = 'Katherine',
}) =>
    {
      'email': email,
      'first_name': firstName,
      'last_name': 'Johnson',
      'company_name': 'NASA',
      'phone': '+1 202 555 0147',
    };
