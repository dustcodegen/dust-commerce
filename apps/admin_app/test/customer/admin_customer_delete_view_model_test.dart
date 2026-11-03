import 'dart:io';

import 'package:admin_app/src/core/admin_api.dart';
import 'package:admin_app/src/customer/admin_customer_api.dart';
import 'package:admin_app/src/customer/admin_customer_delete_state.dart';
import 'package:admin_app/src/customer/admin_customer_delete_view_model.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/commerce_server.dart';
import 'package:dio/dio.dart';
import 'package:dust_server/testing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory directory;
  late CommerceDatabase database;
  late TestClient server;
  late AdminCustomerDeleteViewModel deletion;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('admin_customer_delete');
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
INSERT INTO customers (id, email, first_name, last_name, has_account)
VALUES ('cus_guest', 'guest@example.com', 'Grace', 'Hopper', 0)
''', const []);
    server = await TestClient.serve(buildApp(database));
    final session = AdminApi(Dio(), baseUrl: server.origin);
    final token = await session.signIn(const AdminCredentials(
      email: 'owner@example.com',
      password: 'correct horse battery staple',
    ));
    final dio = Dio()
      ..options.headers['authorization'] = 'Bearer ${token.token}';
    deletion = AdminCustomerDeleteViewModel(AdminCustomerDeleteViewModelArgs(
      api: AdminCustomerApi(dio, baseUrl: server.origin),
    ));
  });

  tearDown(() async {
    await server.close();
    await database.close();
    await directory.delete(recursive: true);
  });

  test('retains the direct deletion acknowledgement', () async {
    final result = await deletion.delete('cus_guest');

    expect(result, isA<Some<AdminCustomerDeleted>>());
    expect(deletion.state.status, AdminCustomerDeleteStatus.ready);
    expect(deletion.state.failure, const None<String>());
    final deleted = (result as Some<AdminCustomerDeleted>).value;
    expect(deleted.id, 'cus_guest');
    expect(deleted.object, 'customer');
    expect(deleted.deleted, isTrue);
  });

  test('maps missing customer without retaining a stale result', () async {
    await deletion.delete('cus_guest');
    final repeat = await deletion.delete('cus_guest');

    expect(repeat, const None<AdminCustomerDeleted>());
    expect(deletion.state.deleted, const None<AdminCustomerDeleted>());
    expect(
      deletion.state.failure,
      const Some('This customer no longer exists.'),
    );
  });

  test('maps an expired Dio-owned session', () async {
    final unauthorized = AdminCustomerDeleteViewModel(
      AdminCustomerDeleteViewModelArgs(
        api: AdminCustomerApi(Dio(), baseUrl: server.origin),
      ),
    );

    await unauthorized.delete('cus_guest');

    expect(
      unauthorized.state.failure,
      const Some('Your admin session has expired.'),
    );
  });
}
