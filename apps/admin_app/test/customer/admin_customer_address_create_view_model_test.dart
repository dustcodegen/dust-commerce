import 'dart:io';

import 'package:admin_app/src/core/admin_api.dart';
import 'package:admin_app/src/customer/admin_customer_address_create_state.dart';
import 'package:admin_app/src/customer/admin_customer_address_create_view_model.dart';
import 'package:admin_app/src/customer/admin_customer_api.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/commerce_server.dart';
import 'package:dio/dio.dart';
import 'package:dust_server/testing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory directory;
  late CommerceDatabase database;
  late TestClient server;
  late AdminCustomerAddressCreateViewModel create;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('admin_address_create');
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
    await database.connection.execute(
      "INSERT INTO customers (id, email) VALUES ('cus_ada', 'ada@example.com')",
      const [],
    );
    var id = 0;
    server = await TestClient.serve(buildApp(
      database,
      nextId: () => 'address_${++id}',
    ));
    final session = AdminApi(Dio(), baseUrl: server.origin);
    final token = await session.signIn(const AdminCredentials(
      email: 'owner@example.com',
      password: 'correct horse battery staple',
    ));
    final dio = Dio()
      ..options.headers['authorization'] = 'Bearer ${token.token}';
    create = AdminCustomerAddressCreateViewModel(
      AdminCustomerAddressCreateViewModelArgs(
        api: AdminCustomerApi(dio, baseUrl: server.origin),
      ),
    );
  });

  tearDown(() async {
    await server.close();
    await database.close();
    await directory.delete(recursive: true);
  });

  test('retains the refreshed customer after address creation', () async {
    final result = await create.create('cus_ada', _address());

    expect(result, isA<Some<AdminCustomerDetail>>());
    expect(create.state.status, AdminCustomerAddressCreateStatus.ready);
    expect(create.state.failure, const None<String>());
    final customer = (result as Some<AdminCustomerDetail>).value;
    expect(customer.addresses, hasLength(1));
    expect(customer.addresses.single.addressName, const Some('Home'));
    expect(customer.addresses.single.city, const None<String>());
  });

  test('maps missing customer and expired Dio session safely', () async {
    await create.create('cus_missing', _address());
    expect(create.state.created, const None<AdminCustomerDetail>());
    expect(
      create.state.failure,
      const Some('This customer no longer exists.'),
    );

    final unauthorized = AdminCustomerAddressCreateViewModel(
      AdminCustomerAddressCreateViewModelArgs(
        api: AdminCustomerApi(Dio(), baseUrl: server.origin),
      ),
    );
    await unauthorized.create('cus_ada', _address());
    expect(
      unauthorized.state.failure,
      const Some('Your admin session has expired.'),
    );
  });
}

AdminCreateCustomerAddress _address() => const AdminCreateCustomerAddress(
      addressName: 'Home',
      line1: '12 St James Square',
      countryCode: 'gb',
      companyValue: null,
      firstNameValue: null,
      lastNameValue: null,
      line2Value: null,
      cityValue: null,
      provinceValue: null,
      postalCodeValue: null,
      phoneValue: null,
    );
