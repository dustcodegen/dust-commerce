import 'dart:convert';

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

  test('password rotation requires the route-level customer guard', () async {
    final response = await _change(harness, null, _oldPassword, _newPassword);

    response.assertUnauthorized();
  });

  test('invalid current and reused passwords preserve every session', () async {
    final wrong = await _change(
      harness,
      token,
      'this is not the current password',
      _newPassword,
    );
    wrong
      ..assertUnprocessable()
      ..assertTextContains('Current password is incorrect');

    final reused = await _change(
      harness,
      token,
      _oldPassword,
      _oldPassword,
    );
    reused
      ..assertUnprocessable()
      ..assertTextContains('Use a different password');

    final current = harness.client.get('/store/customers/me')..bearer(token);
    (await current.send()).assertOk();
  });

  test('valid rotation writes Argon2id and revokes every existing session',
      () async {
    final second = await _signIn(harness, _oldPassword);
    final secondToken =
        (second.json! as Map<String, Object?>)['token']! as String;
    await harness.raw(
      "UPDATE provider_identity SET updated_at = "
      "'2000-01-01T00:00:00.000Z'",
    );

    final changed = await _change(
      harness,
      token,
      _oldPassword,
      _newPassword,
    );

    changed
      ..assertOk()
      ..assertJson({'success': true});
    final provider = (await harness.raw(
      'SELECT provider_metadata, updated_at FROM provider_identity',
    ))
        .single;
    final metadata =
        jsonDecode(provider.readIndex<String>(0)) as Map<String, Object?>;
    final hash = metadata['password']! as String;
    expect(hash, startsWith(r'$argon2id$v=19$m=19456,t=2,p=1$'));
    expect(hash, isNot(contains(_oldPassword)));
    expect(hash, isNot(contains(_newPassword)));
    expect(
      provider.readIndex<DateTime>(1).toUtc(),
      isNot(DateTime.parse('2000-01-01T00:00:00.000Z')),
    );

    for (final revoked in [token, secondToken]) {
      final me = harness.client.get('/store/customers/me')..bearer(revoked);
      (await me.send()).assertUnauthorized();
    }
    (await _signIn(harness, _oldPassword)).assertUnauthorized();
    (await _signIn(harness, _newPassword)).assertOk();
  });

  test('password validation enforces both request boundaries before work',
      () async {
    final shortOld = await _change(harness, token, 'short', _newPassword);
    final shortNew = await _change(harness, token, _oldPassword, 'short');
    final longNew = await _change(
      harness,
      token,
      _oldPassword,
      List.filled(1025, 'x').join(),
    );

    shortOld.assertUnprocessable();
    shortNew.assertUnprocessable();
    longNew.assertUnprocessable();
    (await _signIn(harness, _oldPassword)).assertOk();
  });
}

Future<TestResponse> _change(
  AccountTestHarness harness,
  String? token,
  String oldPassword,
  String newPassword,
) {
  final request = harness.client.patch('/store/customers/me/password')
    ..json({
      'old_password': oldPassword,
      'new_password': newPassword,
    });
  if (token != null) request.bearer(token);
  return request.send();
}

Future<TestResponse> _signIn(
  AccountTestHarness harness,
  String password,
) =>
    (harness.client.post('/auth/customer/emailpass')
          ..json({'email': 'ada@example.com', 'password': password}))
        .send();

const String _oldPassword = AccountTestHarness.password;
const String _newPassword = 'a new correct horse battery staple';
