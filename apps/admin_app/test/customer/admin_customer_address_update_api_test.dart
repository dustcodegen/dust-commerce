import 'dart:io';

import 'package:admin_app/src/core/admin_api.dart';
import 'package:admin_app/src/customer/admin_customer_api.dart';
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
    directory = await Directory.systemTemp.createTemp('admin_address_update');
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
    await database.connection.execute(
      "INSERT INTO customers (id, email) VALUES ('cus_ada', 'ada@example.com')",
      const [],
    );
    await database.connection.execute(r'''
INSERT INTO customer_addresses (
  id, customer_id, address_name, address_1, city, country_code
) VALUES ('addr_home', 'cus_ada', 'Home', '12 St James Square', 'London', 'gb')
''', const []);
    server = await TestClient.serve(buildApp(database));
  });

  tearDown(() async {
    await server.close();
    await database.close();
    await directory.delete(recursive: true);
  });

  test('generated client sends tri-state patch through Dio authorization',
      () async {
    final session = AdminApi(Dio(), baseUrl: server.origin);
    final issued = await session.signIn(const AdminCredentials(
      email: 'owner@example.com',
      password: 'correct horse battery staple',
    ));
    final dio = Dio()
      ..options.headers['authorization'] = 'Bearer ${issued.token}';
    final api = AdminCustomerApi(dio, baseUrl: server.origin);

    final customer = await api.updateCustomerAddress(
      'cus_ada',
      'addr_home',
      const AdminUpdateCustomerAddress(
        addressName: Some('Primary'),
        city: Some<String?>(null),
      ),
    );

    expect(customer.id, 'cus_ada');
    expect(customer.addresses.single.addressName, const Some('Primary'));
    expect(customer.addresses.single.city, const None<String>());
    expect(customer.addresses.single.line1, '12 St James Square');
  });
}
