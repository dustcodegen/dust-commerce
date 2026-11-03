import 'package:dust_server/testing.dart';
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

  test('address CRUD is guarded, allowlisted, normalized, and soft deleted',
      () async {
    final anonymous = harness.client.get('/store/customers/me/addresses');
    (await anonymous.send()).assertUnauthorized();

    final created = await _create(harness, token, _home);
    created.assertCreated();
    expect((created.json! as Map<String, Object?>).keys.toSet(), _addressKeys);
    expect(created.json, containsPair('country_code', 'us'));
    expect(created.json, containsPair('is_default_shipping', true));

    final addressId = (created.json! as Map<String, Object?>)['id']! as String;
    final updated = harness.client.patch(
      '/store/customers/me/addresses/$addressId',
    )
      ..bearer(token)
      ..json({..._home, 'city': 'Arlington', 'is_default_billing': true});
    (await updated.send())
      ..assertOk()
      ..assertJsonContains({
        'id': addressId,
        'city': 'Arlington',
        'is_default_billing': true,
      });

    final listed = harness.client.get('/store/customers/me/addresses')
      ..bearer(token);
    (await listed.send())
      ..assertOk()
      ..assertJsonContains({'count': 1});

    final deleted = harness.client.delete(
      '/store/customers/me/addresses/$addressId',
    )..bearer(token);
    (await deleted.send())
      ..assertOk()
      ..assertJson({'id': addressId, 'success': true});
    expect(
      (await harness.raw(
        'SELECT deleted_at FROM customer_addresses WHERE id = ?',
        [addressId],
      ))
          .single
          .readIndex<DateTime>(0)
          .toUtc()
          .toIso8601String(),
      endsWith('Z'),
    );
  });

  test('default roles remain unique and another customer sees 404', () async {
    final first = await _create(harness, token, _home);
    final firstId = (first.json! as Map<String, Object?>)['id']! as String;
    final second = await _create(harness, token, {
      ..._home,
      'address_1': '22 Second Street',
      'is_default_billing': true,
    });
    final secondId = (second.json! as Map<String, Object?>)['id']! as String;

    final defaults = await harness.raw(
      'SELECT id, is_default_shipping, is_default_billing '
      'FROM customer_addresses ORDER BY id',
    );
    expect(defaults.where((row) => row.readIndex<int>(1) == 1), hasLength(1));
    expect(defaults.where((row) => row.readIndex<int>(2) == 1), hasLength(1));

    final otherToken = await harness.registerAndSignIn(
      email: 'grace@example.com',
      firstName: 'Grace',
      lastName: 'Hopper',
    );
    final wrong = harness.client.patch(
      '/store/customers/me/addresses/$secondId',
    )
      ..bearer(otherToken)
      ..json({..._home, 'city': 'Hidden'});
    (await wrong.send()).assertNotFound();

    final restoreFirst = harness.client.patch(
      '/store/customers/me/addresses/$firstId',
    )
      ..bearer(token)
      ..json({..._home, 'is_default_billing': true});
    (await restoreFirst.send()).assertOk();
  });

  test('address validation rejects invalid country and blank street', () async {
    final response = await _create(harness, token, {
      ..._home,
      'address_1': ' ',
      'country_code': 'USA',
    });

    response.assertUnprocessable();
    expect(await harness.raw('SELECT id FROM customer_addresses'), isEmpty);
  });
}

Future<TestResponse> _create(
  AccountTestHarness harness,
  String token,
  Map<String, Object?> body,
) =>
    (harness.client.post('/store/customers/me/addresses')
          ..bearer(token)
          ..json(body))
        .send();

const _home = <String, Object?>{
  'first_name': ' Ada ',
  'last_name': ' Lovelace ',
  'company': ' Analytical Engines ',
  'phone': ' +1 555 0101 ',
  'address_1': ' 12 First Street ',
  'address_2': ' Suite 2 ',
  'city': ' Washington ',
  'province': ' DC ',
  'postal_code': ' 20001 ',
  'country_code': 'US',
  'is_default_shipping': true,
  'is_default_billing': false,
};

const _addressKeys = {
  'address_1',
  'address_2',
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
};
