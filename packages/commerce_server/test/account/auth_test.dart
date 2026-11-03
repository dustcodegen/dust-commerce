import 'dart:convert';
import 'dart:io';

import 'package:commerce_server/commerce_server.dart';
import 'package:dust_server/testing.dart';
import 'package:test/test.dart';

void main() {
  group('Argon2id passwords', () {
    test('use the production parameters and a fresh salt', () async {
      final first = await Passwords.hash('correct horse battery staple');
      final second = await Passwords.hash('correct horse battery staple');

      expect(first, startsWith(r'$argon2id$v=19$m=19456,t=2,p=1$'));
      expect(second, isNot(first));
      expect(await Passwords.verify('correct horse battery staple', first),
          isTrue);
      expect(await Passwords.verify('wrong password', first), isFalse);
    });
  });

  group('customer accounts', () {
    late _AccountHarness harness;

    setUp(() async => harness = await _AccountHarness.start());
    tearDown(() => harness.stop());

    test('registration persists a Medusa-shaped identity safely', () async {
      final response = await harness.register();

      response
        ..assertCreated()
        ..assertJsonContains({
          'customer': {
            'id': 'id_1',
            'email': 'ada@example.com',
            'first_name': 'Ada',
            'last_name': 'Lovelace',
            'phone': null,
          },
          'verification_required': false,
        });
      expect((response.json! as Map<String, Object?>).keys.toSet(), {
        'customer',
        'verification_required',
      });
      final row = (await harness.raw(
        'SELECT c.has_account, c.created_at, c.updated_at, '
        'p.provider, p.provider_metadata '
        'FROM customers c JOIN auth_identity a '
        r"ON json_extract(a.app_metadata, '$.customer_id') = c.id "
        'JOIN provider_identity p ON p.auth_identity_id = a.id',
      ))
          .single;
      final metadata =
          jsonDecode(row.readIndex<String>(4)) as Map<String, Object?>;

      expect(row.readIndex<int>(0), 1);
      expect(row.readIndex<DateTime>(1).toUtc().isUtc, isTrue);
      expect(row.readIndex<DateTime>(2), row.readIndex<DateTime>(1));
      expect(row.readIndex<String>(3), 'emailpass');
      expect(metadata['password'], startsWith(r'$argon2id$'));
      expect(metadata['password'], isNot(contains(_AccountHarness.password)));
    });

    test('rejects invalid and duplicate account input', () async {
      (await (harness.client.post('/store/customers')
                ..json({'email': 'bad', 'password': 'short'}))
              .send())
          .assertUnprocessable();
      (await harness.register()).assertCreated();
      (await harness.register(email: ' ADA@EXAMPLE.COM ')).assertConflict();
    });

    test('sign-in stores only a token fingerprint and authenticates it',
        () async {
      await harness.register();
      final signedIn = await harness.signIn();
      signedIn.assertOk();
      final body = signedIn.json! as Map<String, Object?>;
      final token = body['token']! as String;
      final stored = (await harness.raw(
        'SELECT token_hash, expires_at FROM auth_tokens',
      ))
          .single;

      expect(stored.readIndex<String>(0), await Tokens.fingerprint(token));
      expect(stored.readIndex<String>(0), isNot(token));
      expect(body['expires_at'], '2100-01-08T12:00:00.000Z');
      expect(stored.readIndex<DateTime>(1).toUtc().toIso8601String(),
          body['expires_at']);

      final me = harness.client.get('/store/customers/me')..bearer(token);
      (await me.send())
        ..assertOk()
        ..assertJsonContains({'id': 'id_1', 'email': 'ada@example.com'});
    });

    test('unknown email and wrong password disclose the same result', () async {
      await harness.register();
      final wrong = await harness.signIn(password: 'definitely wrong password');
      final missing = await harness.signIn(email: 'nobody@example.com');

      wrong.assertUnauthorized();
      missing.assertUnauthorized();
      expect(missing.body, wrong.body);
    });

    test('expired token cannot authenticate', () async {
      await harness.register();
      final token = Tokens.issue();
      await queryExecute(
        'INSERT INTO auth_tokens '
        '(token_hash, auth_identity_id, created_at, expires_at) '
        "VALUES (\$1, 'id_2', '2026-09-04T12:00:00.000Z', "
        "'2026-09-05T11:59:59.000Z')",
        [await Tokens.fingerprint(token)],
      ).execute(harness.database.executor);

      final me = harness.client.get('/store/customers/me')..bearer(token);
      (await me.send()).assertUnauthorized();
    });

    test('sign-out revokes the token', () async {
      await harness.register();
      final signedIn = await harness.signIn();
      final token =
          (signedIn.json! as Map<String, Object?>)['token']! as String;
      final signOut = harness.client.delete('/auth/session')..bearer(token);

      (await signOut.send())
        ..assertOk()
        ..assertJson({'success': true});
      final me = harness.client.get('/store/customers/me')..bearer(token);
      (await me.send()).assertUnauthorized();
    });
  });
}

final class _AccountHarness {
  _AccountHarness._(this.directory, this.database, this.client);

  static Future<_AccountHarness> start() async {
    final directory = await Directory.systemTemp.createTemp('commerce_auth');
    final database = await openTestDatabase(
      '${directory.path}/commerce.db',
      options: commerceOptions,
    );
    var id = 0;
    return _AccountHarness._(
      directory,
      database,
      TestClient(buildApp(
        database,
        nextId: () => 'id_${++id}',
        now: () => DateTime.utc(2100, 1, 1, 12),
      )),
    );
  }

  static const password = 'correct horse battery staple';
  final TestClient client;
  final CommerceDatabase database;
  final Directory directory;

  Future<TestResponse> register({String email = ' Ada@Example.COM '}) =>
      (client.post('/store/customers')
            ..json({
              'email': email,
              'password': password,
              'first_name': 'Ada',
              'last_name': 'Lovelace',
            }))
          .send();

  Future<TestResponse> signIn({
    String email = 'ada@example.com',
    String password = password,
  }) =>
      (client.post('/auth/customer/emailpass')
            ..json({'email': email, 'password': password}))
          .send();

  Future<List<Row>> raw(String sql) =>
      queryRaw(sql, []).fetch(database.connection as Executor);

  Future<void> stop() async {
    await client.close();
    await database.close();
    await directory.delete(recursive: true);
  }
}
