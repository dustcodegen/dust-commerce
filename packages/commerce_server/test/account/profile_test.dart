import 'package:test/test.dart';

import 'support.dart';

void main() {
  late AccountTestHarness harness;
  late String token;

  setUp(() async {
    harness = await AccountTestHarness.start();
    token = await harness.registerAndSignIn();
  });
  tearDown(() => harness.stop());

  test('profile update requires the route-level customer guard', () async {
    final request = harness.client.patch('/store/customers/me')..json(_profile);

    (await request.send()).assertUnauthorized();
  });

  test('profile update trims public fields and returns only the allowlist',
      () async {
    await harness.raw(
      "UPDATE customers SET updated_at = '2000-01-01T00:00:00.000Z' "
      "WHERE id = 'id_1'",
    );
    final request = harness.client.patch('/store/customers/me')
      ..bearer(token)
      ..json(_profile);
    final response = await request.send();

    response.assertOk();
    expect(response.json, {
      'email': 'ada@example.com',
      'first_name': 'Grace',
      'id': 'id_1',
      'last_name': 'Hopper',
      'phone': '+1 555 0100',
    });
    final row = (await harness.raw(
      'SELECT first_name, last_name, phone, updated_at FROM customers '
      "WHERE id = 'id_1'",
    ))
        .single;
    expect(row.readIndex<String>(0), 'Grace');
    expect(row.readIndex<String>(1), 'Hopper');
    expect(row.readIndex<String>(2), '+1 555 0100');
    expect(
      row.readIndex<DateTime>(3).toUtc(),
      isNot(DateTime.parse('2000-01-01T00:00:00.000Z')),
    );
  });

  test('profile validation rejects blank names before persistence', () async {
    final request = harness.client.patch('/store/customers/me')
      ..bearer(token)
      ..json({..._profile, 'first_name': '  '});

    (await request.send()).assertUnprocessable();
    final row = (await harness.raw(
      "SELECT first_name FROM customers WHERE id = 'id_1'",
    ))
        .single;
    expect(row.readIndex<String>(0), 'Ada');
  });
}

const _profile = {
  'first_name': ' Grace ',
  'last_name': ' Hopper ',
  'phone': ' +1 555 0100 ',
};
