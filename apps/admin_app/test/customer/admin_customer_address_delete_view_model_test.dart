import 'dart:io';

import 'package:admin_app/src/core/admin_api.dart';
import 'package:admin_app/src/customer/admin_customer_address_delete_state.dart';
import 'package:admin_app/src/customer/admin_customer_address_delete_view_model.dart';
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
  late AdminCustomerAddressDeleteViewModel deletion;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('admin_address_delete');
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
INSERT INTO customer_addresses
  (id, customer_id, address_name, address_1, country_code)
VALUES ('addr_home', 'cus_ada', 'Home', '12 St James Square', 'gb')
''', const []);
    server = await TestClient.serve(buildApp(database));
    final session = AdminApi(Dio(), baseUrl: server.origin);
    final token = await session.signIn(const AdminCredentials(
      email: 'owner@example.com',
      password: 'correct horse battery staple',
    ));
    final dio = Dio()
      ..options.headers['authorization'] = 'Bearer ${token.token}';
    deletion = AdminCustomerAddressDeleteViewModel(
      AdminCustomerAddressDeleteViewModelArgs(
        api: AdminCustomerApi(dio, baseUrl: server.origin),
      ),
    );
  });

  tearDown(() async {
    await server.close();
    await database.close();
    await directory.delete(recursive: true);
  });

  test('retains the direct delete-with-parent acknowledgement', () async {
    final result = await deletion.delete('cus_ada', 'addr_home');

    expect(result, isA<Some<AdminCustomerAddressDeleted>>());
    expect(deletion.state.status, AdminCustomerAddressDeleteStatus.ready);
    expect(deletion.state.failure, const None<String>());
    final deleted = (result as Some<AdminCustomerAddressDeleted>).value;
    expect(deleted.id, 'addr_home');
    expect(deleted.object, 'customer_address');
    expect(deleted.deleted, isTrue);
    expect(
      deleted.parent.map((customer) => customer.addresses.length),
      const Some(0),
    );
  });

  test('maps missing address and expired Dio session safely', () async {
    await deletion.delete('cus_ada', 'addr_missing');
    expect(deletion.state.deleted, const None<AdminCustomerAddressDeleted>());
    expect(
      deletion.state.failure,
      const Some('This address no longer exists.'),
    );

    final unauthorized = AdminCustomerAddressDeleteViewModel(
      AdminCustomerAddressDeleteViewModelArgs(
        api: AdminCustomerApi(Dio(), baseUrl: server.origin),
      ),
    );
    await unauthorized.delete('cus_ada', 'addr_home');
    expect(
      unauthorized.state.failure,
      const Some('Your admin session has expired.'),
    );
  });
}
