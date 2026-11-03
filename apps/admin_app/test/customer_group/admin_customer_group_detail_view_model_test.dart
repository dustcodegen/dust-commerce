import 'dart:io';

import 'package:admin_app/src/core/admin_api.dart';
import 'package:admin_app/src/customer_group/admin_customer_group_api.dart';
import 'package:admin_app/src/customer_group/admin_customer_group_detail_state.dart';
import 'package:admin_app/src/customer_group/admin_customer_group_detail_view_model.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/commerce_server.dart';
import 'package:dio/dio.dart';
import 'package:dust_server/testing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory directory;
  late CommerceDatabase database;
  late TestClient server;
  late AdminCustomerGroupDetailViewModel detail;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('admin_group_detail');
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
    await _seedDetail(database);
    server = await TestClient.serve(buildApp(database));
    final sessions = AdminApi(Dio(), baseUrl: server.origin);
    final token = await sessions.signIn(const AdminCredentials(
      email: 'owner@example.com',
      password: 'correct horse battery staple',
    ));
    final dio = Dio()
      ..options.headers['authorization'] = 'Bearer ${token.token}';
    detail = AdminCustomerGroupDetailViewModel(
      AdminCustomerGroupDetailViewModelArgs(
        api: AdminCustomerGroupApi(dio, baseUrl: server.origin),
      ),
    );
  });

  tearDown(() async {
    await server.close();
    await database.close();
    await directory.delete(recursive: true);
  });

  test('loads typed group detail and its customer page', () async {
    await detail.load('cusgrp_vip');

    expect(detail.state.status, AdminCustomerGroupDetailStatus.ready);
    final group = switch (detail.state.customerGroup) {
      Some(:final value) => value,
      None() => fail('customer-group detail was absent'),
    };
    expect(group.name, 'VIP');
    final metadata = switch (group.metadata) {
      Some(:final value) => value,
      None() => fail('customer-group metadata was absent'),
    };
    expect(metadata, {'source': 'admin'});
    expect(
        detail.state.customersStatus, AdminCustomerGroupCustomersStatus.ready);
    expect(detail.state.customers.map((value) => value.id), [
      'cus_guest',
      'cus_ada',
    ]);
    expect(detail.state.customerCount, 2);
  });

  test('keeps detail while searching its customer section', () async {
    await detail.load('cusgrp_vip');
    await detail.searchCustomers('ada');

    expect(detail.state.customerGroup, isA<Some<AdminCustomerGroupDetail>>());
    expect(detail.state.customerQuery, 'ada');
    expect(detail.state.customers.single.id, 'cus_ada');
  });

  test('maps an unavailable group to display-safe state', () async {
    await detail.load('cusgrp_missing');

    expect(detail.state.status, AdminCustomerGroupDetailStatus.failed);
    expect(detail.state.customerGroup, const None<AdminCustomerGroupDetail>());
    expect(
      detail.state.failure,
      const Some('This customer group no longer exists.'),
    );
  });
}

Future<void> _seedDetail(CommerceDatabase database) async {
  await database.connection.execute(r'''
INSERT INTO customers
  (id, email, first_name, last_name, has_account, created_at, updated_at)
VALUES
  ('cus_ada', 'ada@example.com', 'Ada', 'Lovelace', 1,
   '2026-09-10T10:00:00.000Z', '2026-09-10T10:00:00.000Z'),
  ('cus_guest', 'guest@example.com', 'Grace', 'Hopper', 0,
   '2026-09-11T10:00:00.000Z', '2026-09-11T10:00:00.000Z')
''', const []);
  await database.connection.execute(r'''
INSERT INTO customer_groups (id, name, metadata)
VALUES ('cusgrp_vip', 'VIP', '{"source":"admin"}')
''', const []);
  await database.connection.execute(r'''
INSERT INTO customer_group_customers
  (id, customer_group_id, customer_id)
VALUES
  ('cgc_vip_ada', 'cusgrp_vip', 'cus_ada'),
  ('cgc_vip_guest', 'cusgrp_vip', 'cus_guest')
''', const []);
}
