import 'dart:io';

import 'package:admin_app/src/core/admin_api.dart';
import 'package:admin_app/src/customer_group/admin_customer_group_api.dart';
import 'package:admin_app/src/customer_group/admin_customer_group_state.dart';
import 'package:admin_app/src/customer_group/admin_customer_group_view_model.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/commerce_server.dart';
import 'package:dio/dio.dart';
import 'package:dust_server/testing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory directory;
  late CommerceDatabase database;
  late TestClient server;
  late AdminCustomerGroupApi api;
  late AdminCustomerGroupViewModel groups;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('admin_groups');
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
    await _seedGroups(database);
    server = await TestClient.serve(buildApp(database));
    final sessionApi = AdminApi(Dio(), baseUrl: server.origin);
    final token = await sessionApi.signIn(const AdminCredentials(
      email: 'owner@example.com',
      password: 'correct horse battery staple',
    ));
    final dio = Dio()
      ..options.headers['authorization'] = 'Bearer ${token.token}';
    api = AdminCustomerGroupApi(dio, baseUrl: server.origin);
    groups = AdminCustomerGroupViewModel(
      AdminCustomerGroupViewModelArgs(api: api),
    );
  });

  tearDown(() async {
    await server.close();
    await database.close();
    await directory.delete(recursive: true);
  });

  test('loads decoded groups and active customer counts', () async {
    final response =
        await api.listCustomerGroups('', '', '', '-created_at', 10, 0);
    await groups.load();

    expect(response.count, 2);
    expect(groups.state.status, AdminCustomerGroupStatus.ready);
    expect(groups.state.customerGroups.map((value) => value.id), [
      'cusgrp_vip',
      'cusgrp_retail',
    ]);
    expect(groups.state.customerGroups.first.customers, hasLength(1));
    expect(groups.state.customerGroups.first.createdAt.isUtc, isTrue);
  });

  test('keeps search, date, and ordering controls in state', () async {
    await groups.filterByUpdatedAt(
      from: Some(DateTime.utc(2026, 9, 12)),
      to: Some(DateTime.utc(2026, 9, 12, 23, 59, 59)),
    );

    expect(groups.state.customerGroups.single.id, 'cusgrp_vip');
    expect(
      groups.state.updatedAt.greaterThanOrEqual,
      Some(DateTime.utc(2026, 9, 12)),
    );

    await groups.clearFilters();
    await groups.search('Retail');
    await groups.filterByCreatedAt(
      from: Some(DateTime.utc(2026, 9, 10)),
      to: Some(DateTime.utc(2026, 9, 10, 23, 59, 59)),
    );
    await groups.orderBy(AdminCustomerGroupOrder.nameAsc);

    expect(groups.state.query, 'Retail');
    expect(groups.state.order, AdminCustomerGroupOrder.nameAsc);
    expect(groups.state.customerGroups.single.id, 'cusgrp_retail');
  });

  test('reports an expired Admin session', () async {
    final unauthorized = AdminCustomerGroupViewModel(
      AdminCustomerGroupViewModelArgs(
        api: AdminCustomerGroupApi(Dio(), baseUrl: server.origin),
      ),
    );

    await unauthorized.load();

    expect(unauthorized.state.status, AdminCustomerGroupStatus.failed);
    expect(
      unauthorized.state.failure,
      const Some('Your admin session has expired.'),
    );
  });
}

Future<void> _seedGroups(CommerceDatabase database) async {
  await database.connection.execute(r'''
INSERT INTO customers (id, email, has_account)
VALUES ('cus_ada', 'ada@example.com', 1)
''', const []);
  await database.connection.execute(r'''
INSERT INTO customer_groups (id, name, created_at, updated_at)
VALUES
  ('cusgrp_retail', 'Retail',
   '2026-09-10T10:00:00.000Z', '2026-09-10T10:05:00.000Z'),
  ('cusgrp_vip', 'VIP',
   '2026-09-12T10:00:00.000Z', '2026-09-12T10:05:00.000Z')
''', const []);
  await database.connection.execute(r'''
INSERT INTO customer_group_customers
  (id, customer_group_id, customer_id)
VALUES ('cgc_vip_ada', 'cusgrp_vip', 'cus_ada')
''', const []);
}
