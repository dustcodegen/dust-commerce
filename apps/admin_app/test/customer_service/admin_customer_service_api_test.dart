import 'dart:io';

import 'package:admin_app/src/core/admin_api.dart';
import 'package:admin_app/src/customer_service/admin_customer_service_api.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/commerce_server.dart';
import 'package:dio/dio.dart';
import 'package:dust_server/testing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory directory;
  late CommerceDatabase database;
  late TestClient server;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('admin_support');
    database = await openTestDatabase(
      '${directory.path}/commerce.db',
      options: commerceOptions,
    );
    await bootstrapAdmin(
      database,
      const AdminCredentials(
        email: 'owner@example.com',
        password: 'correct horse battery staple',
      ),
      nextId: () => 'admin_owner',
      passwordWork: PasswordWorkLimiter(),
    );
    await database.connection.execute(r'''
INSERT INTO customer_service_requests (
  id, name, email, subject, message, order_reference
) VALUES (
  'csr_01', 'Ada Lovelace', 'ada@example.com', 'Damaged cup',
  'The espresso cup arrived damaged.', 'ORDER-42'
)
''', const []);
    server = await TestClient.serve(buildApp(database));
  });

  tearDown(() async {
    await server.close();
    await database.close();
    await directory.delete(recursive: true);
  });

  test('generated Admin client lists and resolves a support request', () async {
    final session = AdminApi(Dio(), baseUrl: server.origin);
    final issued = await session.signIn(const AdminCredentials(
      email: 'owner@example.com',
      password: 'correct horse battery staple',
    ));
    final dio = Dio()
      ..options.headers['authorization'] = 'Bearer ${issued.token}';
    final api = AdminCustomerServiceApi(dio, baseUrl: server.origin);

    final page = await api.list(
      'damaged',
      'open',
      '-created_at',
      20,
      0,
    );
    final resolved = await api.update(
      page.requests.single.id,
      const AdminUpdateCustomerService(
        status: AdminCustomerServiceStatus.resolved,
      ),
    );

    expect(page.count, 1);
    expect(page.requests.single.createdAt.isUtc, isTrue);
    expect(resolved.status, AdminCustomerServiceStatus.resolved);
    expect(resolved.resolvedAtValue?.isUtc, isTrue);
    expect(resolved.updatedAt.isUtc, isTrue);
  });

  test('generated Admin client cannot list without authorization', () async {
    final api = AdminCustomerServiceApi(Dio(), baseUrl: server.origin);

    await expectLater(
      api.list('', '', '-created_at', 20, 0),
      throwsA(isA<DioException>().having(
        (error) => error.response?.statusCode,
        'statusCode',
        401,
      )),
    );
  });
}
