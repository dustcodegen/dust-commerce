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
  late CommerceApi api;
  final now = DateTime.utc(2100, 1, 1, 12);

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('account_password');
    database = await openTestDatabase(
      '${directory.path}/commerce.db',
      options: commerceOptions,
    );
    server = await TestClient.serve(buildApp(database, now: () => now));
    sessions = MemoryAuthSessionStore();
    final dio = Dio()
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

  Future<AccountViewModel> registered() async {
    final account = model();
    await account.register(
      email: 'ada@example.com',
      password: _oldPassword,
      firstName: 'Ada',
      lastName: 'Lovelace',
    );
    return account;
  }

  test('password change revokes the bearer and requires the new secret',
      () async {
    final account = await registered();
    final oldToken = sessions.value!.token;

    expect(
      await account.changePassword(
        oldPassword: _oldPassword,
        newPassword: _newPassword,
      ),
      isTrue,
    );
    expect(account.state.status, AccountStatus.signedOut);
    expect(sessions.value, isNull);

    final oldBearer = Dio();
    oldBearer.options.headers['authorization'] = 'Bearer $oldToken';
    final oldApi = CommerceApi(oldBearer, baseUrl: server.origin);
    await expectLater(
      oldApi.currentCustomer(),
      throwsA(isA<DioException>().having(
        (error) => error.response?.statusCode,
        'status',
        401,
      )),
    );
    expect(
      await account.signIn(email: 'ada@example.com', password: _oldPassword),
      isFalse,
    );
    expect(
      await account.signIn(email: 'ada@example.com', password: _newPassword),
      isTrue,
    );
  });

  test('wrong current password keeps the verified customer signed in',
      () async {
    final account = await registered();

    expect(
      await account.changePassword(
        oldPassword: 'this is not the current password',
        newPassword: _newPassword,
      ),
      isFalse,
    );
    expect(account.state.status, AccountStatus.failed);
    expect(account.state.customer?.email, 'ada@example.com');
    expect(account.state.message, 'Current password is incorrect');
    expect(sessions.value, isNotNull);
  });
}

const _oldPassword = 'correct horse battery staple';
const _newPassword = 'a new correct horse battery staple';
