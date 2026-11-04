import 'dart:io';

import 'package:admin_app/src/core/admin_api.dart';
import 'package:admin_app/src/customer_group/admin_customer_group_api.dart';
import 'package:admin_app/src/customer_group/admin_customer_group_create_state.dart';
import 'package:admin_app/src/customer_group/admin_customer_group_create_view_model.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/commerce_server.dart';
import 'package:dio/dio.dart';
import 'package:dust_server/testing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory directory;
  late CommerceDatabase database;
  late TestClient server;
  late AdminCustomerGroupCreateViewModel create;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('admin_group_create');
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
    server = await TestClient.serve(buildApp(
      database,
      nextId: () => 'cusgrp_created',
    ));
    final sessions = AdminApi(Dio(), baseUrl: server.origin);
    final token = await sessions.signIn(const AdminCredentials(
      email: 'owner@example.com',
      password: 'correct horse battery staple',
    ));
    final dio = Dio()
      ..options.headers['authorization'] = 'Bearer ${token.token}';
    create = AdminCustomerGroupCreateViewModel(
      AdminCustomerGroupCreateViewModelArgs(
        api: AdminCustomerGroupApi(dio, baseUrl: server.origin),
      ),
    );
  });

  tearDown(() async {
    await server.close();
    await database.close();
    await directory.delete(recursive: true);
  });

  test('retains the typed group returned by the generated Dio client',
      () async {
    final result = await create.create(_input('  Regional Partners  '));

    expect(result, isA<Some<AdminCustomerGroup>>());
    expect(create.state.status, AdminCustomerGroupCreateStatus.ready);
    expect(create.state.failure, const None<String>());
    final group = (result as Some<AdminCustomerGroup>).value;
    expect(group.id, 'cusgrp_created');
    expect(group.name, 'Regional Partners');
    expect(group.customers, isEmpty);
    expect(group.createdAt.isUtc, isTrue);
  });

  test('maps validation and expired sessions to display-safe failures',
      () async {
    await create.create(_input('   '));
    expect(
      create.state.failure,
      const Some('Check the customer group details and try again.'),
    );

    final unauthorized = AdminCustomerGroupCreateViewModel(
      AdminCustomerGroupCreateViewModelArgs(
        api: AdminCustomerGroupApi(Dio(), baseUrl: server.origin),
      ),
    );
    await unauthorized.create(_input('Regional Partners'));
    expect(
      unauthorized.state.failure,
      const Some('Your admin session has expired.'),
    );
  });
}

AdminCreateCustomerGroup _input(String name) => AdminCreateCustomerGroup(
      name: name,
      metadataValue: null,
    );
