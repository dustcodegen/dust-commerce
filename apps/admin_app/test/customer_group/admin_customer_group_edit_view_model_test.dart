import 'dart:io';

import 'package:admin_app/src/core/admin_api.dart';
import 'package:admin_app/src/customer_group/admin_customer_group_api.dart';
import 'package:admin_app/src/customer_group/admin_customer_group_edit_state.dart';
import 'package:admin_app/src/customer_group/admin_customer_group_edit_view_model.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/commerce_server.dart';
import 'package:dio/dio.dart';
import 'package:dust_server/testing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory directory;
  late CommerceDatabase database;
  late TestClient server;
  late AdminCustomerGroupEditViewModel edit;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('admin_group_edit');
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
INSERT INTO customer_groups (id, name, metadata)
VALUES ('cusgrp_partners', 'Partners', '{"source":"admin"}')
''', const []);
    server = await TestClient.serve(buildApp(database));
    final sessions = AdminApi(Dio(), baseUrl: server.origin);
    final token = await sessions.signIn(const AdminCredentials(
      email: 'owner@example.com',
      password: 'correct horse battery staple',
    ));
    final dio = Dio()
      ..options.headers['authorization'] = 'Bearer ${token.token}';
    edit = AdminCustomerGroupEditViewModel(
      AdminCustomerGroupEditViewModelArgs(
        api: AdminCustomerGroupApi(dio, baseUrl: server.origin),
      ),
    );
  });

  tearDown(() async {
    await server.close();
    await database.close();
    await directory.delete(recursive: true);
  });

  test('retains refreshed group detail from the generated Dio client',
      () async {
    final result = await edit.update(
      'cusgrp_partners',
      const AdminUpdateCustomerGroup(name: '  Regional Partners  '),
    );

    expect(result, isA<Some<AdminCustomerGroupDetail>>());
    expect(edit.state.status, AdminCustomerGroupEditStatus.ready);
    expect(edit.state.failure, const None<String>());
    final group = (result as Some<AdminCustomerGroupDetail>).value;
    expect(edit.state.updated, Some(group));
    expect(group.id, 'cusgrp_partners');
    expect(group.name, 'Regional Partners');
    expect(group.customers, isEmpty);
    expect(group.metadata, isA<Some<Map<String, Object?>>>());
    expect(
      (group.metadata as Some<Map<String, Object?>>).value,
      {'source': 'admin'},
    );
    expect(group.updatedAt.isUtc, isTrue);
  });

  test('maps validation, missing groups, and expired sessions', () async {
    await edit.update(
      'cusgrp_partners',
      const AdminUpdateCustomerGroup(name: '   '),
    );
    expect(
      edit.state.failure,
      const Some('Check the customer group details and try again.'),
    );

    await edit.update(
      'cusgrp_missing',
      const AdminUpdateCustomerGroup(name: 'Missing'),
    );
    expect(
      edit.state.failure,
      const Some('This customer group no longer exists.'),
    );

    final unauthorized = AdminCustomerGroupEditViewModel(
      AdminCustomerGroupEditViewModelArgs(
        api: AdminCustomerGroupApi(Dio(), baseUrl: server.origin),
      ),
    );
    await unauthorized.update(
      'cusgrp_partners',
      const AdminUpdateCustomerGroup(name: 'Regional Partners'),
    );
    expect(
      unauthorized.state.failure,
      const Some('Your admin session has expired.'),
    );
  });
}
