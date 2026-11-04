import 'dart:io';

import 'package:admin_app/src/core/admin_api.dart';
import 'package:admin_app/src/order/admin_order_state.dart';
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
  late AdminApi api;
  late AdminOrderRegionApi regionApi;
  late AdminOrderSalesChannelApi salesChannelApi;
  late AdminOrderViewModel orders;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('admin_orders');
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
    final anonymous = AdminApi(Dio(), baseUrl: server.origin);
    final token = await anonymous.signIn(const AdminCredentials(
      email: 'owner@example.com',
      password: 'correct horse battery staple',
    ));
    final dio = Dio()
      ..options.headers['authorization'] = 'Bearer ${token.token}';
    api = AdminApi(dio, baseUrl: server.origin);
    regionApi = AdminOrderRegionApi(dio, baseUrl: server.origin);
    salesChannelApi = AdminOrderSalesChannelApi(dio, baseUrl: server.origin);
    orders = AdminOrderViewModel(AdminOrderViewModelArgs(
      api: api,
      exports: AdminOrderExportApi(dio, baseUrl: server.origin),
      regions: regionApi,
      salesChannels: salesChannelApi,
    ));
  });

  tearDown(() async {
    await server.close();
    await database.close();
    await directory.delete(recursive: true);
  });

  test('loads decoded newest-first order summaries', () async {
    final response = await api.listOrders(
      '',
      '',
      '',
      '',
      '',
      '',
      '-created_at',
      20,
      0,
    );
    await orders.load();

    expect(response.count, 2);
    expect(orders.state.status, AdminOrderListStatus.ready);
    expect(orders.state.count, 2);
    expect(orders.state.orders.map((order) => order.displayId), [1002, 1001]);
    expect(orders.state.orders.first.createdAt.isUtc, isTrue);
    expect(orders.state.orders.first.fulfillmentStatus,
        AdminOrderFulfillmentStatus.notFulfilled);
  });

  test('keeps Medusa query filters and ordering in state', () async {
    await orders.search('#1001');
    await orders.filterByStatuses(const [AdminOrderStatus.completed]);
    await orders.filterByRegions(const ['reg_eu']);
    await orders.filterByCreatedAt(
      from: Some(DateTime.utc(2026, 9, 10)),
      to: Some(DateTime.utc(2026, 9, 10, 23, 59, 59)),
    );
    await orders.orderBy(AdminOrderOrder.displayIdAsc);

    expect(orders.state.query, '#1001');
    expect(orders.state.statuses, const [AdminOrderStatus.completed]);
    expect(orders.state.regionIds, const ['reg_eu']);
    expect(orders.state.order, AdminOrderOrder.displayIdAsc);
    expect(orders.state.count, 1);
    expect(orders.state.orders.single.customerName, 'Ada Lovelace');
  });

  test('loads real selling-region filter choices', () async {
    final response = await regionApi.listRegions('', 1000, 0);
    await orders.loadFilterOptions();

    expect(response.regions.map((region) => region.name), [
      'Europe',
      'United States',
    ]);
    expect(
      orders.state.filterOptionsStatus,
      AdminOrderFilterOptionsStatus.ready,
    );
    expect(orders.state.regions, response.regions);
  });

  test('reports an expired admin session', () async {
    final unauthorized = AdminOrderViewModel(AdminOrderViewModelArgs(
      api: AdminApi(Dio(), baseUrl: server.origin),
      exports: AdminOrderExportApi(Dio(), baseUrl: server.origin),
      regions: AdminOrderRegionApi(Dio(), baseUrl: server.origin),
      salesChannels: AdminOrderSalesChannelApi(Dio(), baseUrl: server.origin),
    ));

    await unauthorized.load();
    await unauthorized.loadFilterOptions();

    expect(unauthorized.state.status, AdminOrderListStatus.failed);
    expect(
      unauthorized.state.failure,
      const Some('Your admin session has expired.'),
    );
    expect(
      unauthorized.state.filterOptionsFailure,
      const Some('Your admin session has expired.'),
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
