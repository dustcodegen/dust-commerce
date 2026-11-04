import 'dart:io';

import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_server/commerce_server.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_dart/http.dart';
import 'package:dust_server/testing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('generated client completes the customer session lifecycle', () async {
    final directory = await Directory.systemTemp.createTemp('commerce_client');
    final database = await openTestDatabase(
      '${directory.path}/commerce.db',
      options: commerceOptions,
    );
    var id = 0;
    final server = await TestClient.serve(buildApp(
      database,
      nextId: () => 'id_${++id}',
      now: () => DateTime.utc(2100, 1, 1, 12),
    ));
    final dio = Dio();
    final api = CommerceApi(dio, baseUrl: server.origin);
    addTearDown(() async {
      await server.close();
      await database.close();
      await directory.delete(recursive: true);
    });

    final registered = await api.registerAccount(
      const RegisterAccountBody(
        email: 'ada@example.com',
        password: 'correct horse battery staple',
        firstName: 'Ada',
      ),
    );
    final issued = await api.signIn(
      const Credentials(
        email: 'ada@example.com',
        password: 'correct horse battery staple',
      ),
    );
    final authorization = 'Bearer ${issued.token}';
    dio.options.headers['authorization'] = authorization;

    expect(registered.customer.email, 'ada@example.com');
    expect(await api.currentCustomer(), registered.customer);
    expect((await api.signOut()).success, isTrue);
  });
}
