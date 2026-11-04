import 'dart:io';

import 'package:admin_app/src/core/admin_api.dart';
import 'package:admin_app/src/customer/admin_customer_api.dart';
import 'package:admin_app/src/customer/admin_customer_edit_state.dart';
import 'package:admin_app/src/customer/admin_customer_edit_view_model.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/commerce_server.dart';
import 'package:dio/dio.dart';
import 'package:dust_server/testing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory directory;
  late CommerceDatabase database;
  late TestClient server;
  late AdminCustomerEditViewModel edit;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('admin_customer_edit');
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
    final session = AdminApi(Dio(), baseUrl: server.origin);
    final token = await session.signIn(const AdminCredentials(
      email: 'owner@example.com',
      password: 'correct horse battery staple',
    ));
    final dio = Dio()
      ..options.headers['authorization'] = 'Bearer ${token.token}';
    edit = AdminCustomerEditViewModel(AdminCustomerEditViewModelArgs(
      api: AdminCustomerApi(dio, baseUrl: server.origin),
    ));
  });

  tearDown(() async {
    await server.close();
    await database.close();
    await directory.delete(recursive: true);
  });

  test('retains the direct updated guest response', () async {
    final result = await edit.update(
        'cus_guest',
        _update(
          email: '  NEW@Example.com ',
          company: null,
        ));

    expect(result, isA<Some<AdminCustomerDetail>>());
    expect(edit.state.status, AdminCustomerEditStatus.ready);
    final customer = (result as Some<AdminCustomerDetail>).value;
    expect(customer.email, const Some('new@example.com'));
    expect(customer.companyName, const None<String>());
    expect(customer.firstName, const Some('Grace'));
  });

  test('registered edit omits email and clears nullable contact data',
      () async {
    final result = await edit.update(
        'cus_account',
        _update(
          email: null,
          company: null,
          phone: null,
        ));

    final customer = (result as Some<AdminCustomerDetail>).value;
    expect(customer.email, const Some('ada@example.com'));
    expect(customer.companyName, const None<String>());
    expect(customer.phone, const None<String>());
  });

  test('maps conflict and expired Dio-owned session', () async {
    await edit.update('cus_guest', _update(email: 'other@example.com'));
    expect(
      edit.state.failure,
      const Some('This email cannot be used for this customer.'),
    );

    final unauthorized = AdminCustomerEditViewModel(
      AdminCustomerEditViewModelArgs(
        api: AdminCustomerApi(Dio(), baseUrl: server.origin),
      ),
    );
    await unauthorized.update('cus_guest', _update());
    expect(
      unauthorized.state.failure,
      const Some('Your admin session has expired.'),
    );
  });
}

AdminUpdateCustomer _update({
  String? email = 'guest@example.com',
  String? company = 'Navy',
  String? phone = '+1 202 555 0147',
}) =>
    AdminUpdateCustomer(
      emailValue: email,
      companyNameValue: company,
      firstNameValue: 'Grace',
      lastNameValue: 'Hopper',
      phoneValue: phone,
    );

Future<void> _seedCustomers(CommerceDatabase database) async {
  await database.connection.execute(r'''
INSERT INTO customers
  (id, email, company_name, first_name, last_name, phone, has_account)
VALUES
  ('cus_guest', 'guest@example.com', 'Navy', 'Grace', 'Hopper',
   '+1 202 555 0147', 0),
  ('cus_account', 'ada@example.com', 'Engines', 'Ada', 'Lovelace',
   '+44 20 0000 0000', 1),
  ('cus_other', 'other@example.com', NULL, 'Other', 'Guest', NULL, 0)
''', const []);
}
