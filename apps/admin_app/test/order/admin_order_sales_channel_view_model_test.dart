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
  late AdminOrderViewModel orders;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('admin_order_channel');
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
    orders = AdminOrderViewModel(AdminOrderViewModelArgs(
      api: AdminApi(dio, baseUrl: server.origin),
      exports: AdminOrderExportApi(dio, baseUrl: server.origin),
      regions: AdminOrderRegionApi(dio, baseUrl: server.origin),
      salesChannels: AdminOrderSalesChannelApi(dio, baseUrl: server.origin),
    ));
  });

  tearDown(() async {
    await server.close();
    await database.close();
    await directory.delete(recursive: true);
  });

  test('loads, filters, labels, and exports real sales channels', () async {
    await orders.loadFilterOptions();
    await orders.filterBySalesChannels(const ['sc_wholesale']);
    final exported = await orders.export();

    expect(orders.state.salesChannels.map((value) => value.name), [
      'Online Store',
      'Wholesale',
    ]);
    expect(orders.state.salesChannelIds, const ['sc_wholesale']);
    expect(orders.state.count, 1);
    expect(orders.state.orders.single.id, 'ord_wholesale');
    expect(
      orders.state.orders.single.salesChannelName,
      const Some('Wholesale'),
    );
    expect(exported, isA<Ok<String, String>>());
    expect((exported as Ok<String, String>).value, contains('ord_wholesale'));
    expect(exported.value, isNot(contains('ord_web')));
  });
}

Future<void> _seedOrders(CommerceDatabase database) async {
  await database.connection.execute(r'''
INSERT INTO carts (id, region_id, email, completed_at)
VALUES
  ('cart_web', 'reg_eu', 'web@example.com', '2026-09-10T10:00:00.000Z'),
  ('cart_wholesale', 'reg_us', 'buyer@example.com',
   '2026-09-11T10:00:00.000Z')
''', const []);
  await database.connection.execute(r'''
INSERT INTO cart_sales_channels (cart_id, sales_channel_id)
VALUES ('cart_web', 'sc_web'), ('cart_wholesale', 'sc_wholesale')
''', const []);
  await database.connection.execute(r'''
INSERT INTO orders
  (id, display_id, cart_id, region_id, email, currency_code, subtotal, tax,
   total, placed_at, created_at, updated_at)
VALUES
  ('ord_web', 1001, 'cart_web', 'reg_eu', 'web@example.com', 'eur', 1000, 0,
   1000, '2026-09-10T10:00:00.000Z', '2026-09-10T10:00:00.000Z',
   '2026-09-10T10:05:00.000Z'),
  ('ord_wholesale', 1002, 'cart_wholesale', 'reg_us', 'buyer@example.com',
   'usd', 2000, 0, 2000, '2026-09-11T10:00:00.000Z',
   '2026-09-11T10:00:00.000Z', '2026-09-11T10:05:00.000Z')
''', const []);
  await database.connection.execute(r'''
INSERT INTO order_sales_channels (order_id, sales_channel_id)
VALUES ('ord_web', 'sc_web'), ('ord_wholesale', 'sc_wholesale')
''', const []);
}
