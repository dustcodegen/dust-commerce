import 'dart:io';

import 'package:admin_app/src/core/admin_api.dart';
import 'package:admin_app/src/customer_group/admin_customer_group_api.dart';
import 'package:admin_app/src/customer_group/admin_customer_group_candidate_state.dart';
import 'package:admin_app/src/customer_group/admin_customer_group_candidate_view_model.dart';
import 'package:admin_app/src/customer_group/admin_customer_group_membership_state.dart';
import 'package:admin_app/src/customer_group/admin_customer_group_membership_view_model.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/commerce_server.dart';
import 'package:dio/dio.dart';
import 'package:dust_server/testing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory directory;
  late CommerceDatabase database;
  late TestClient server;
  late AdminCustomerGroupMembershipViewModel memberships;
  late AdminCustomerGroupCandidateViewModel candidates;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('admin_group_membership');
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
INSERT INTO customers (id, email, first_name, last_name)
VALUES
  ('cus_ada', 'ada@example.com', 'Ada', 'Lovelace'),
  ('cus_grace', 'grace@example.com', 'Grace', 'Hopper')
''', const []);
    await database.connection.execute(r'''
INSERT INTO customer_groups (id, name)
VALUES ('cusgrp_partners', 'Partners')
''', const []);
    await database.connection.execute(r'''
INSERT INTO customer_group_customers
  (id, customer_group_id, customer_id)
VALUES ('cgc_ada', 'cusgrp_partners', 'cus_ada')
''', const []);
    server = await TestClient.serve(buildApp(database));
    final sessionApi = AdminApi(Dio(), baseUrl: server.origin);
    final token = await sessionApi.signIn(const AdminCredentials(
      email: 'owner@example.com',
      password: 'correct horse battery staple',
    ));
    final dio = Dio()
      ..options.headers['authorization'] = 'Bearer ${token.token}';
    memberships = AdminCustomerGroupMembershipViewModel(
      AdminCustomerGroupMembershipViewModelArgs(
        api: AdminCustomerGroupApi(dio, baseUrl: server.origin),
      ),
    );
    candidates = AdminCustomerGroupCandidateViewModel(
      AdminCustomerGroupCandidateViewModelArgs(
        api: AdminCustomerGroupApi(dio, baseUrl: server.origin),
      ),
    );
  });

  tearDown(() async {
    await server.close();
    await database.close();
    await directory.delete(recursive: true);
  });

  test('retains refreshed detail from one generated membership call', () async {
    final result = await memberships.update(
      'cusgrp_partners',
      add: ['cus_grace'],
      remove: ['cus_ada'],
    );

    expect(result, isA<Some<AdminCustomerGroupDetail>>());
    expect(memberships.state.status, AdminCustomerGroupMembershipStatus.ready);
    expect(memberships.state.failure, const None<String>());
    final group = (result as Some<AdminCustomerGroupDetail>).value;
    expect(group.customers.map((customer) => customer.id), ['cus_grace']);
    expect(memberships.state.customerGroup, Some(group));
  });

  test('maps invalid customers and expired Dio-owned sessions', () async {
    await memberships.update('cusgrp_partners', add: ['cus_missing']);
    expect(
      memberships.state.failure,
      const Some('One or more customers cannot be updated.'),
    );

    final unauthorized = AdminCustomerGroupMembershipViewModel(
      AdminCustomerGroupMembershipViewModelArgs(
        api: AdminCustomerGroupApi(Dio(), baseUrl: server.origin),
      ),
    );
    await unauthorized.update('cusgrp_partners', remove: ['cus_ada']);
    expect(
      unauthorized.state.failure,
      const Some('Your admin session has expired.'),
    );
  });

  test('loads an independent searchable 10-row candidate page', () async {
    await candidates.load();

    expect(candidates.state.status, AdminCustomerGroupCandidateStatus.ready);
    expect(candidates.state.count, 2);
    expect(candidates.state.limit, 10);
    expect(candidates.state.customers.map((customer) => customer.id),
        ['cus_ada', 'cus_grace']);

    await candidates.search('Ada');
    expect(candidates.state.count, 1);
    expect(candidates.state.customers.single.id, 'cus_ada');
  });
}
