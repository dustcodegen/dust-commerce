import 'dart:io';

import 'package:admin_app/src/core/admin_api.dart';
import 'package:admin_app/src/customer_group/admin_customer_group_api.dart';
import 'package:admin_app/src/customer_group/admin_customer_group_delete_state.dart';
import 'package:admin_app/src/customer_group/admin_customer_group_delete_view_model.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/commerce_server.dart';
import 'package:dio/dio.dart';
import 'package:dust_server/testing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory directory;
  late CommerceDatabase database;
  late TestClient server;
  late AdminCustomerGroupDeleteViewModel deletion;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('admin_group_delete');
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
INSERT INTO customer_groups (id, name)
VALUES ('cusgrp_partners', 'Partners')
''', const []);
    server = await TestClient.serve(buildApp(database));
    final sessions = AdminApi(Dio(), baseUrl: server.origin);
    final token = await sessions.signIn(const AdminCredentials(
      email: 'owner@example.com',
      password: 'correct horse battery staple',
    ));
    final dio = Dio()
      ..options.headers['authorization'] = 'Bearer ${token.token}';
    deletion = AdminCustomerGroupDeleteViewModel(
      AdminCustomerGroupDeleteViewModelArgs(
        api: AdminCustomerGroupApi(dio, baseUrl: server.origin),
      ),
    );
  });

  tearDown(() async {
    await server.close();
    await database.close();
    await directory.delete(recursive: true);
  });

  test('retains the direct deletion acknowledgement', () async {
    final result = await deletion.delete('cusgrp_partners');

    expect(result, isA<Some<AdminCustomerGroupDeleted>>());
    expect(deletion.state.status, AdminCustomerGroupDeleteStatus.ready);
    expect(deletion.state.failure, const None<String>());
    final deleted = (result as Some<AdminCustomerGroupDeleted>).value;
    expect(deletion.state.deleted, Some(deleted));
    expect(deleted.id, 'cusgrp_partners');
    expect(deleted.object, 'customer_group');
    expect(deleted.deleted, isTrue);
  });

  test('maps missing groups and expired Dio-owned sessions', () async {
    await deletion.delete('cusgrp_missing');
    expect(
      deletion.state.failure,
      const Some('This customer group no longer exists.'),
    );

    final unauthorized = AdminCustomerGroupDeleteViewModel(
      AdminCustomerGroupDeleteViewModelArgs(
        api: AdminCustomerGroupApi(Dio(), baseUrl: server.origin),
      ),
    );
    await unauthorized.delete('cusgrp_partners');
    expect(
      unauthorized.state.failure,
      const Some('Your admin session has expired.'),
    );
  });
}
