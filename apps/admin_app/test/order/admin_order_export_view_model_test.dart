import 'dart:io';

import 'package:admin_app/src/core/admin_api.dart';
import 'package:admin_app/src/order/admin_order_export_api.dart';
import 'package:admin_app/src/order/admin_order_region_api.dart';
import 'package:admin_app/src/order/admin_order_sales_channel_api.dart';
import 'package:admin_app/src/order/admin_order_view_model.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/commerce_server.dart';
import 'package:dio/dio.dart';
import 'package:dust_server/testing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory directory;
  late CommerceDatabase database;
  late TestClient server;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('admin_order_export');
    database = await openTestDatabase(
      '${directory.path}/commerce.db',
      options: commerceOptions,
    );
    await seedDevelopmentStore(database);
    await bootstrapAdmin(
      database,
      const AdminCredentials(
        email: 'owner@example.com',
        password: 'correct horse battery staple',
      ),
      nextId: () => 'admin_owner',
      passwordWork: PasswordWorkLimiter(),
    );
    await _seedOrders(database);
    server = await TestClient.serve(buildApp(database));
  });

  tearDown(() async {
    await server.close();
    await database.close();
    await directory.delete(recursive: true);
  });

  test('exports the complete set using current order filters', () async {
    final anonymous = AdminApi(Dio(), baseUrl: server.origin);
    final token = await anonymous.signIn(const AdminCredentials(
      email: 'owner@example.com',
      password: 'correct horse battery staple',
    ));
    final dio = Dio()
      ..options.headers['authorization'] = 'Bearer ${token.token}';
    final orders = AdminOrderViewModel(AdminOrderViewModelArgs(
      api: AdminApi(dio, baseUrl: server.origin),
      exports: AdminOrderExportApi(dio, baseUrl: server.origin),
      regions: AdminOrderRegionApi(dio, baseUrl: server.origin),
      salesChannels: AdminOrderSalesChannelApi(dio, baseUrl: server.origin),
    ));

    await orders.load(
      query: '#1001',
      statuses: const [AdminOrderStatus.completed],
      regionIds: const ['reg_eu'],
      order: AdminOrderOrder.displayIdAsc,
    );
    final result = await orders.export();
    final csv = switch (result) {
      Ok(:final value) => value,
      Err(:final error) => fail(error),
    };

    expect(csv, contains('ord_1001,1001,completed,captured'));
    expect(csv, isNot(contains('ord_1002')));
  });

  test('maps an expired export session to display-safe copy', () async {
    final dio = Dio();
    final orders = AdminOrderViewModel(AdminOrderViewModelArgs(
      api: AdminApi(dio, baseUrl: server.origin),
      exports: AdminOrderExportApi(dio, baseUrl: server.origin),
      regions: AdminOrderRegionApi(dio, baseUrl: server.origin),
      salesChannels: AdminOrderSalesChannelApi(dio, baseUrl: server.origin),
    ));

    expect(
      await orders.export(),
      const Err<String, String>('Your admin session has expired.'),
    );
  });
}

Future<void> _seedOrders(CommerceDatabase database) async {
  await database.connection.execute(r'''
INSERT INTO customers (id, email, first_name, last_name, has_account)
VALUES ('cus_ada', 'ada@example.com', 'Ada', 'Lovelace', 1)
''', const []);
  await database.connection.execute(r'''
INSERT INTO carts (id, region_id, customer_id, email, completed_at)
VALUES
  ('cart_1001', 'reg_eu', 'cus_ada', 'ada@example.com',
   '2026-09-10T10:00:00.000Z'),
  ('cart_1002', 'reg_us', NULL, 'guest@example.com',
   '2026-09-11T10:00:00.000Z')
''', const []);
  await database.connection.execute(r'''
INSERT INTO orders
  (id, display_id, cart_id, region_id, customer_id, email, currency_code,
   subtotal, tax, total, status, payment_status, placed_at, created_at,
   updated_at)
VALUES
  ('ord_1001', 1001, 'cart_1001', 'reg_eu', 'cus_ada', 'ada@example.com',
   'eur', 2500, 0, 2500, 'completed', 'captured',
   '2026-09-10T10:00:00.000Z', '2026-09-10T10:00:00.000Z',
   '2026-09-10T10:05:00.000Z'),
  ('ord_1002', 1002, 'cart_1002', 'reg_us', NULL, 'guest@example.com',
   'usd', 1500, 0, 1500, 'pending', 'awaiting',
   '2026-09-11T10:00:00.000Z', '2026-09-11T10:00:00.000Z',
   '2026-09-11T10:05:00.000Z')
''', const []);
}
