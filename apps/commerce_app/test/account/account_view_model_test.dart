import 'dart:io';

import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_server/commerce_server.dart';
import 'package:dio/dio.dart';
import 'package:dust_server/testing.dart';
import 'package:flutter_test/flutter_test.dart';

import '../core/support.dart';

void main() {
  late Directory directory;
  late CommerceDatabase database;
  late TestClient server;
  late MemoryAuthSessionStore sessions;
  late Dio dio;
  late CommerceApi api;
  final now = DateTime.utc(2100, 1, 1, 12);

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('account_view_model');
    database = await openTestDatabase(
      '${directory.path}/commerce.db',
      options: commerceOptions,
    );
    server = await TestClient.serve(buildApp(database, now: () => now));
    sessions = MemoryAuthSessionStore();
    dio = Dio()
      ..interceptors.add(
        AuthorizationInterceptor(sessions: sessions, now: () => now),
      );
    api = CommerceApi(dio, baseUrl: server.origin);
  });

  tearDown(() async {
    await server.close();
    await database.close();
    await directory.delete(recursive: true);
  });

  AccountViewModel model() => AccountViewModel(
        AccountViewModelArgs(api: api, sessions: sessions, now: () => now),
      );

  test('registers, securely persists, and restores a verified session',
      () async {
    final first = model();

    expect(
      await first.register(
        email: 'ada@example.com',
        password: 'correct horse battery staple',
        firstName: 'Ada',
        lastName: 'Lovelace',
      ),
      isTrue,
    );
    expect(first.state.customer?.email, 'ada@example.com');
    expect(sessions.value?.token, isNotEmpty);
    expect(first.state.toString(), isNot(contains(sessions.value!.token)));

    final restarted = model();
    await restarted.restore();

    expect(restarted.state.status, AccountStatus.signedIn);
    expect(restarted.state.customer?.displayName, 'Ada Lovelace');
  });

  test('invalid credentials produce a display-safe signed-out state', () async {
    await model().register(
      email: 'ada@example.com',
      password: 'correct horse battery staple',
      firstName: 'Ada',
      lastName: 'Lovelace',
    );
    await model().signOut();
    final account = model();

    expect(
      await account.signIn(
        email: 'ada@example.com',
        password: 'definitely not the password',
      ),
      isFalse,
    );
    expect(account.state.status, AccountStatus.failed);
    expect(account.state.message, 'The email or password is incorrect.');
    expect(account.state.customer, isNull);
  });

  test('restore clears an expired session without sending it', () async {
    sessions.value = StoredAuthSession(
      token: 'expired-secret',
      expiresAt: now.subtract(const Duration(seconds: 1)),
    );
    final account = model();

    await account.restore();

    expect(account.state.status, AccountStatus.signedOut);
    expect(sessions.value, isNull);
  });

  test('restore clears a server-rejected bearer session', () async {
    sessions.value = StoredAuthSession(
      token: 'not-a-server-token',
      expiresAt: now.add(const Duration(hours: 1)),
    );
    final account = model();

    await account.restore();

    expect(account.state.status, AccountStatus.signedOut);
    expect(sessions.value, isNull);
  });

  test('sign out revokes the server token before clearing local state',
      () async {
    final account = model();
    await account.register(
      email: 'ada@example.com',
      password: 'correct horse battery staple',
      firstName: 'Ada',
      lastName: 'Lovelace',
    );
    final oldToken = sessions.value!.token;

    expect(await account.signOut(), isTrue);
    expect(account.state.status, AccountStatus.signedOut);
    expect(sessions.value, isNull);

    final rejected = Dio();
    rejected.options.headers['authorization'] = 'Bearer $oldToken';
    final rejectedApi = CommerceApi(rejected, baseUrl: server.origin);
    await expectLater(
      rejectedApi.currentCustomer(),
      throwsA(
        isA<DioException>().having(
          (error) => error.response?.statusCode,
          'status',
          401,
        ),
      ),
    );
  });

  test('profile update replaces the public customer without exposing auth',
      () async {
    final account = model();
    await account.register(
      email: 'ada@example.com',
      password: 'correct horse battery staple',
      firstName: 'Ada',
      lastName: 'Lovelace',
    );

    expect(
      await account.updateProfile(
        firstName: 'Grace',
        lastName: 'Hopper',
        phone: '+1 555 0100',
      ),
      isTrue,
    );
    expect(account.state.status, AccountStatus.signedIn);
    expect(account.state.customer?.displayName, 'Grace Hopper');
    expect(account.state.customer?.phone, '+1 555 0100');
    expect(account.state.toString(), isNot(contains(sessions.value!.token)));
  });
}
