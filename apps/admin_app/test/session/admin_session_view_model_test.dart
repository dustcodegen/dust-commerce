import 'dart:io';

import 'package:admin_app/src/core/admin_api.dart';
import 'package:admin_app/src/core/admin_authorization_interceptor.dart';
import 'package:admin_app/src/core/admin_session_store.dart';
import 'package:admin_app/src/session/admin_session_state.dart';
import 'package:admin_app/src/session/admin_session_view_model.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/commerce_server.dart';
import 'package:dio/dio.dart';
import 'package:dust_server/testing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const password = 'correct horse battery staple';
  final now = DateTime.utc(2100, 1, 1, 12);
  late Directory directory;
  late CommerceDatabase database;
  late TestClient server;
  late MemoryAdminSessionStore sessions;
  late AdminApi api;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('admin_session');
    database = await openTestDatabase(
      '${directory.path}/commerce.db',
      options: commerceOptions,
    );
    var id = 0;
    final bootstrapped = await bootstrapAdmin(
      database,
      const AdminCredentials(email: 'owner@example.com', password: password),
      nextId: () => 'admin_${++id}',
      passwordWork: PasswordWorkLimiter(),
    );
    expect(bootstrapped, isA<Ok<Object, Object>>());
    server = await TestClient.serve(buildApp(database, now: () => now));
    sessions = MemoryAdminSessionStore();
    final dio = Dio()
      ..interceptors.add(
        AdminAuthorizationInterceptor(sessions: sessions, now: () => now),
      );
    api = AdminApi(dio, baseUrl: server.origin);
  });

  tearDown(() async {
    await server.close();
    await database.close();
    await directory.delete(recursive: true);
  });

  AdminSessionViewModel model() => AdminSessionViewModel(
        AdminSessionViewModelArgs(
          api: api,
          sessions: sessions,
          now: () => now,
        ),
      );

  test('signs in, stores DateTime expiry, and restores the admin', () async {
    final first = model();

    expect(await first.signIn(' OWNER@EXAMPLE.COM ', password), isTrue);
    expect(first.state.status, AdminSessionStatus.signedIn);
    expect(sessions.value, isA<Some<StoredAdminSession>>());
    final stored = (sessions.value as Some<StoredAdminSession>).value;
    expect(stored.expiresAt, DateTime.utc(2100, 1, 8, 12));
    expect(first.state.toString(), isNot(contains(stored.token)));

    final restarted = model();
    await restarted.restore();

    expect(restarted.state.status, AdminSessionStatus.signedIn);
    expect(
      (restarted.state.user as Some<AdminUser>).value.email,
      'owner@example.com',
    );
  });

  test('normalizes offset-bearing stored expiry to UTC', () {
    final stored = StoredAdminSession.fromJson({
      'token': 'session-token',
      'expires_at': '2100-01-08T18:30:00+06:30',
    });

    expect(stored.expiresAt, DateTime.utc(2100, 1, 8, 12));
    expect(stored.expiresAt.isUtc, isTrue);
  });

  test('expired local bearer is cleared without an API request', () async {
    sessions.value = Some(StoredAdminSession(
      token: 'expired-secret',
      expiresAt: now.subtract(const Duration(seconds: 1)),
    ));
    final admin = model();

    await admin.restore();

    expect(admin.state.status, AdminSessionStatus.signedOut);
    expect(sessions.value, const None<StoredAdminSession>());
  });

  test('sign out revokes the server bearer and clears storage', () async {
    final admin = model();
    await admin.signIn('owner@example.com', password);
    final stored = (sessions.value as Some<StoredAdminSession>).value;

    await admin.signOut();

    expect(admin.state.status, AdminSessionStatus.signedOut);
    expect(sessions.value, const None<StoredAdminSession>());
    final rejected = Dio()
      ..options.headers['authorization'] = 'Bearer ${stored.token}';
    await expectLater(
      AdminApi(rejected, baseUrl: server.origin).currentUser(),
      throwsA(
        isA<DioException>().having(
          (error) => error.response?.statusCode,
          'status',
          401,
        ),
      ),
    );
  });
}

final class MemoryAdminSessionStore implements AdminSessionStore {
  Option<StoredAdminSession> value = const None();

  @override
  Future<void> clear() async => value = const None();

  @override
  Future<Option<StoredAdminSession>> read() async => value;

  @override
  Future<void> write(AdminIssuedToken token) async {
    value = Some(StoredAdminSession(
      token: token.token,
      expiresAt: token.expiresAt,
    ));
  }
}
