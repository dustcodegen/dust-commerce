import 'dart:io';

import 'package:admin_app/src/core/admin_api.dart';
import 'package:admin_app/src/customer/admin_customer_api.dart';
import 'package:admin_app/src/customer/admin_customer_detail_state.dart';
import 'package:admin_app/src/customer/admin_customer_detail_view_model.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/commerce_server.dart';
import 'package:dio/dio.dart';
import 'package:dust_server/testing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory directory;
  late CommerceDatabase database;
  late TestClient server;
  late AdminCustomerDetailViewModel detail;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('admin_customer_detail');
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
    await seedDevelopmentStore(database);
    await _seedDetail(database);
    server = await TestClient.serve(buildApp(database));
    final session = AdminApi(Dio(), baseUrl: server.origin);
    final token = await session.signIn(const AdminCredentials(
      email: 'owner@example.com',
      password: 'correct horse battery staple',
    ));
    final dio = Dio()
      ..options.headers['authorization'] = 'Bearer ${token.token}';
    detail = AdminCustomerDetailViewModel(AdminCustomerDetailViewModelArgs(
      api: AdminCustomerApi(dio, baseUrl: server.origin),
    ));
  });

  tearDown(() async {
    await server.close();
    await database.close();
    await directory.delete(recursive: true);
  });

  test('loads the allowlisted customer and customer-scoped orders', () async {
    await detail.load('cus_ada');

    expect(detail.state.status, AdminCustomerDetailStatus.ready);
    expect(detail.state.customer, isA<Some<AdminCustomerDetail>>());
    final customer = switch (detail.state.customer) {
      Some(:final value) => value,
      None() => fail('customer detail was absent'),
    };
    expect(customer.addresses.single.city, const Some('London'));
    expect(detail.state.ordersStatus, AdminCustomerOrdersStatus.ready);
    expect(detail.state.orders.map((order) => order.id), ['ord_ada']);
    expect(detail.state.orderCount, 1);
  });

  test('keeps customer detail while changing the order query', () async {
    await detail.load('cus_ada');
    await detail.searchOrders('1001');

    expect(detail.state.customer, isA<Some<AdminCustomerDetail>>());
    expect(detail.state.orderQuery, '1001');
    expect(detail.state.orders.single.displayId, 1001);
  });

  test('maps an unavailable customer to display-safe state', () async {
    await detail.load('cus_missing');

    expect(detail.state.status, AdminCustomerDetailStatus.failed);
    expect(detail.state.customer, const None<AdminCustomerDetail>());
    expect(detail.state.failure, const Some('This customer no longer exists.'));
  });
}

Future<void> _seedDetail(CommerceDatabase database) async {
  await database.connection.execute(r'''
INSERT INTO customers
  (id, email, company_name, first_name, last_name, phone, has_account)
VALUES
  ('cus_ada', 'ada@example.com', 'Analytical Engines', 'Ada', 'Lovelace',
   '+44 20 0000 0000', 1)
''', const []);
  await database.connection.execute(r'''
INSERT INTO customer_addresses
  (id, customer_id, first_name, last_name, address_1, city, postal_code,
   country_code, is_default_shipping)
VALUES
  ('addr_ada', 'cus_ada', 'Ada', 'Lovelace', '12 St James Square', 'London',
   'SW1Y 4LB', 'gb', 1)
''', const []);
  await database.connection.execute(r'''
INSERT INTO carts (id, region_id, customer_id, email, completed_at)
VALUES ('cart_ada', 'reg_eu', 'cus_ada', 'ada@example.com',
        '2026-09-14T01:00:00.000Z')
''', const []);
  await database.connection.execute(r'''
INSERT INTO orders
  (id, display_id, cart_id, region_id, customer_id, email, currency_code,
   subtotal, tax, total, status, payment_status, placed_at)
VALUES
  ('ord_ada', 1001, 'cart_ada', 'reg_eu', 'cus_ada', 'ada@example.com',
   'eur', 2500, 0, 2500, 'completed', 'captured',
   '2026-09-14T01:00:00.000Z')
''', const []);
}
