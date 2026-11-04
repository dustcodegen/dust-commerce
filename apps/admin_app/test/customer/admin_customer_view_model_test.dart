import 'dart:io';

import 'package:admin_app/src/core/admin_api.dart';
import 'package:admin_app/src/customer/admin_customer_api.dart';
import 'package:admin_app/src/customer/admin_customer_state.dart';
import 'package:admin_app/src/customer/admin_customer_view_model.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/commerce_server.dart';
import 'package:dio/dio.dart';
import 'package:dust_server/testing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory directory;
  late CommerceDatabase database;
  late TestClient server;
  late AdminCustomerApi api;
  late AdminCustomerViewModel customers;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('admin_customers');
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
    await _seedCustomers(database);
    server = await TestClient.serve(buildApp(database));
    final sessionApi = AdminApi(Dio(), baseUrl: server.origin);
    final token = await sessionApi.signIn(const AdminCredentials(
      email: 'owner@example.com',
      password: 'correct horse battery staple',
    ));
    final dio = Dio()
      ..options.headers['authorization'] = 'Bearer ${token.token}';
    api = AdminCustomerApi(dio, baseUrl: server.origin);
    customers = AdminCustomerViewModel(AdminCustomerViewModelArgs(api: api));
  });

  tearDown(() async {
    await server.close();
    await database.close();
    await directory.delete(recursive: true);
  });

  test('loads decoded newest-first customer summaries', () async {
    final response =
        await api.listCustomers('', '', '', '', '-created_at', 20, 0);
    await customers.load();

    expect(response.count, 2);
    expect(customers.state.status, AdminCustomerListStatus.ready);
    expect(customers.state.customers.map((value) => value.id), [
      'cus_guest',
      'cus_ada',
    ]);
    expect(customers.state.customers.first.createdAt.isUtc, isTrue);
  });

  test('keeps account, date, and ordering filters in state', () async {
    await customers.search('ADA');
    await customers.filterByAccount(const Some(true));
    await customers.filterByCreatedAt(
      from: Some(DateTime.utc(2026, 9, 10)),
      to: Some(DateTime.utc(2026, 9, 10, 23, 59, 59)),
    );
    await customers.orderBy(AdminCustomerOrder.emailAsc);

    expect(customers.state.query, 'ADA');
    expect(customers.state.hasAccount, const Some(true));
    expect(customers.state.order, AdminCustomerOrder.emailAsc);
    expect(customers.state.customers.single.id, 'cus_ada');
  });

  test('reports an expired admin session', () async {
    final unauthorized = AdminCustomerViewModel(AdminCustomerViewModelArgs(
      api: AdminCustomerApi(Dio(), baseUrl: server.origin),
    ));

    await unauthorized.load();

    expect(unauthorized.state.status, AdminCustomerListStatus.failed);
    expect(
      unauthorized.state.failure,
      const Some('Your admin session has expired.'),
    );
  });
}

Future<void> _seedCustomers(CommerceDatabase database) =>
    database.connection.execute(r'''
INSERT INTO customers
  (id, email, first_name, last_name, has_account, created_at, updated_at)
VALUES
  ('cus_ada', 'ada@example.com', 'Ada', 'Lovelace', 1,
   '2026-09-10T10:00:00.000Z', '2026-09-10T10:05:00.000Z'),
  ('cus_guest', 'guest@example.com', 'Grace', 'Hopper', 0,
   '2026-09-12T10:00:00.000Z', '2026-09-12T10:05:00.000Z')
''', const []);
