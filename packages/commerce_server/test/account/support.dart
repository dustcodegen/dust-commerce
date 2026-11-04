import 'dart:io';

import 'package:commerce_server/commerce_server.dart';
import 'package:dust_server/testing.dart';

final class AccountTestHarness {
  AccountTestHarness._(this.directory, this.database, this.client);

  static const password = 'correct horse battery staple';

  static Future<AccountTestHarness> start() async {
    final directory = await Directory.systemTemp.createTemp('commerce_account');
    final database = await openTestDatabase(
      '${directory.path}/commerce.db',
      options: commerceOptions,
    );
    var id = 0;
    return AccountTestHarness._(
      directory,
      database,
      TestClient(buildApp(
        database,
        nextId: () => 'id_${++id}',
        now: () => DateTime.utc(2100, 1, 1, 12),
      )),
    );
  }

  final TestClient client;
  final CommerceDatabase database;
  final Directory directory;

  Future<TestResponse> register({
    String email = 'ada@example.com',
    String firstName = 'Ada',
    String lastName = 'Lovelace',
  }) =>
      (client.post('/store/customers')
            ..json({
              'email': email,
              'password': password,
              'first_name': firstName,
              'last_name': lastName,
            }))
          .send();

  Future<String> registerAndSignIn({
    String email = 'ada@example.com',
    String firstName = 'Ada',
    String lastName = 'Lovelace',
  }) async {
    (await register(
      email: email,
      firstName: firstName,
      lastName: lastName,
    ))
        .assertCreated();
    final response = await (client.post('/auth/customer/emailpass')
          ..json({'email': email, 'password': password}))
        .send();
    response.assertOk();
    return (response.json! as Map<String, Object?>)['token']! as String;
  }

  Future<List<Row>> raw(String sql, [List<Object?> parameters = const []]) =>
      queryRaw(sql, parameters).fetch(database.connection as Executor);

  Future<void> stop() async {
    await client.close();
    await database.close();
    await directory.delete(recursive: true);
  }
}
