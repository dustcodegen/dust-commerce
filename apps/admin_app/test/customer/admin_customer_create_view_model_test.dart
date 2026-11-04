import 'dart:io';

import 'package:admin_app/src/core/admin_api.dart';
import 'package:admin_app/src/customer/admin_customer_api.dart';
import 'package:admin_app/src/customer/admin_customer_create_state.dart';
import 'package:admin_app/src/customer/admin_customer_create_view_model.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/commerce_server.dart';
import 'package:dio/dio.dart';
import 'package:dust_server/testing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory directory;
  late CommerceDatabase database;
  late TestClient server;
  late AdminCustomerCreateViewModel create;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('admin_customer_create');
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
    var id = 0;
    server = await TestClient.serve(buildApp(
      database,
      nextId: () => 'customer_${++id}',
    ));
    final session = AdminApi(Dio(), baseUrl: server.origin);
    final token = await session.signIn(const AdminCredentials(
      email: 'owner@example.com',
      password: 'correct horse battery staple',
    ));
    final dio = Dio()
      ..options.headers['authorization'] = 'Bearer ${token.token}';
    create = AdminCustomerCreateViewModel(AdminCustomerCreateViewModelArgs(
      api: AdminCustomerApi(dio, baseUrl: server.origin),
    ));
  });

  tearDown(() async {
    await server.close();
    await database.close();
    await directory.delete(recursive: true);
  });

  test('retains the direct created customer response', () async {
    final result = await create.create(_customer(
      email: '  KATHERINE@Example.com ',
    ));

    expect(result, isA<Some<AdminCustomerDetail>>());
    expect(create.state.status, AdminCustomerCreateStatus.ready);
    expect(create.state.failure, const None<String>());
    final customer = (result as Some<AdminCustomerDetail>).value;
    expect(customer.id, 'customer_1');
    expect(customer.email, const Some('katherine@example.com'));
    expect(customer.hasAccount, isFalse);
    expect(customer.addresses, isEmpty);
    expect(customer.createdAt.isUtc, isTrue);
  });

  test('maps guest-email conflict without retaining a stale result', () async {
    await create.create(_customer());

    final duplicate = await create.create(_customer(firstName: 'Replacement'));

    expect(duplicate, const None<AdminCustomerDetail>());
    expect(create.state.created, const None<AdminCustomerDetail>());
    expect(
      create.state.failure,
      const Some('A guest customer already uses this email.'),
    );
  });

  test('maps an expired Dio-owned session', () async {
    final unauthorized = AdminCustomerCreateViewModel(
      AdminCustomerCreateViewModelArgs(
        api: AdminCustomerApi(Dio(), baseUrl: server.origin),
      ),
    );

    await unauthorized.create(_customer());

    expect(
      unauthorized.state.failure,
      const Some('Your admin session has expired.'),
    );
  });
}

AdminCreateCustomer _customer({
  String email = 'customer@example.com',
  String firstName = 'Katherine',
}) =>
    AdminCreateCustomer(
      email: email,
      companyNameValue: 'NASA',
      firstNameValue: firstName,
      lastNameValue: 'Johnson',
      phoneValue: '+1 202 555 0147',
    );
