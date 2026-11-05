import 'dart:convert';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/commerce_server.dart';
import 'package:test/test.dart';

import 'support.dart';

void main() {
  group('admin authentication', () {
    late AdminHarness harness;

    setUp(() async => harness = await AdminHarness.start());
    tearDown(() => harness.stop());

    test('bootstrap stores a separate Argon2id admin identity', () async {
      final rows = await harness.raw(
        'SELECT u.id, u.email, u.created_at, p.provider, '
        'p.provider_metadata, a.app_metadata '
        'FROM admin_users u JOIN auth_identity a '
        r"ON json_extract(a.app_metadata, '$.admin_user_id') = u.id "
        'JOIN provider_identity p ON p.auth_identity_id = a.id',
      );
      final row = rows.single;
      final provider =
          jsonDecode(row.readIndex<String>(4)) as Map<String, Object?>;

      expect(row.readIndex<String>(0), 'admin_1');
      expect(row.readIndex<String>(1), 'owner@example.com');
      expect(row.readIndex<DateTime>(2).toUtc().isUtc, isTrue);
      expect(row.readIndex<String>(3), 'emailpass_admin');
      expect(provider['password'], startsWith(r'$argon2id$'));
      expect(provider['password'], isNot(contains(AdminHarness.password)));
      expect(jsonDecode(row.readIndex<String>(5)), {
        'admin_user_id': 'admin_1',
      });
    });

    test('bootstrap is repeat-safe for an existing email', () async {
      var next = 20;
      final repeated = await bootstrapAdmin(
        harness.database,
        const AdminCredentials(
          email: 'owner@example.com',
          password: 'another correct horse battery staple',
        ),
        nextId: () => 'repeat_${++next}',
        passwordWork: PasswordWorkLimiter(),
      );
      if (repeated
          case Err(
            error: AdminBootstrapRejected(:final failure),
          )) {
        expect(failure, AdminBootstrapFailure.alreadyExists);
      } else {
        fail('Repeated bootstrap unexpectedly succeeded: $repeated');
      }
      final counts = await harness.raw(
        "SELECT (SELECT count(*) FROM admin_users), "
        "(SELECT count(*) FROM provider_identity "
        " WHERE provider = 'emailpass_admin')",
      );
      expect(counts.single.readIndex<int>(0), 1);
      expect(counts.single.readIndex<int>(1), 1);
    });

    test('admin token reaches only the guarded admin tree', () async {
      final token = await harness.adminToken();
      final stored = (await harness.raw(
        'SELECT token_hash FROM auth_tokens',
      ))
          .single
          .readIndex<String>(0);
      expect(stored, await Tokens.fingerprint(token));
      expect(stored, isNot(token));

      final me = harness.client.get('/admin/users/me')..bearer(token);
      (await me.send())
        ..assertOk()
        ..assertJson({
          'email': 'owner@example.com',
          'first_name': 'Store',
          'id': 'admin_1',
          'last_name': 'Owner',
        });
      final customerMe = harness.client.get('/store/customers/me')
        ..bearer(token);
      (await customerMe.send()).assertUnauthorized();
    });

    test('customer and admin can share an email without sharing authority',
        () async {
      final register = harness.client.post('/store/customers')
        ..json({
          'email': 'owner@example.com',
          'password': AdminHarness.password,
        });
      (await register.send()).assertCreated();
      final customerSignIn = harness.client.post('/auth/customer/emailpass')
        ..json({
          'email': 'owner@example.com',
          'password': AdminHarness.password,
        });
      final response = await customerSignIn.send();
      response.assertOk();
      final token =
          (response.json! as Map<String, Object?>)['token']! as String;
      final adminMe = harness.client.get('/admin/users/me')..bearer(token);
      (await adminMe.send()).assertUnauthorized();
    });

    test('unknown email and wrong password disclose the same result', () async {
      final wrong = await harness.signIn(password: 'definitely wrong password');
      final missing = await harness.signIn(email: 'missing@example.com');

      wrong.assertUnauthorized();
      missing.assertUnauthorized();
      expect(missing.body, wrong.body);
    });

    test('disabled users cannot start or continue a session', () async {
      final token = await harness.adminToken();
      await queryExecute(
        "UPDATE admin_users SET status = 'disabled' WHERE id = 'admin_1'",
        [],
      ).execute(harness.database.executor);

      (await harness.signIn()).assertUnauthorized();
      final me = harness.client.get('/admin/users/me')..bearer(token);
      (await me.send()).assertUnauthorized();
    });

    test('logout revokes the current token', () async {
      final token = await harness.adminToken();
      final logout = harness.client.delete('/auth/admin/session')
        ..bearer(token);
      (await logout.send())
        ..assertOk()
        ..assertJson({'success': true});

      final me = harness.client.get('/admin/users/me')..bearer(token);
      (await me.send()).assertUnauthorized();
    });

    test('there is no public admin registration route', () async {
      (await (harness.client.post('/admin/users')
                ..json({
                  'email': 'public@example.com',
                  'password': AdminHarness.password,
                }))
              .send())
          .assertNotFound();
    });
  });
}
