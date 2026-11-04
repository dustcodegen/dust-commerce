import 'package:test/test.dart';

import 'support.dart';

void main() {
  late AdminHarness harness;

  setUp(() async {
    harness = await AdminHarness.start(seedStore: true);
    await _seedOrders(harness);
  });
  tearDown(() => harness.stop());

  test('order list filters by channel and returns its display label', () async {
    final token = await harness.adminToken();
    final request = harness.client.get(
      '/admin/orders?sales_channel_id=sc_wholesale&order=display_id',
    )..bearer(token);

    final response = await request.send();

    response.assertOk();
    final body = response.json! as Map<String, Object?>;
    expect(body, containsPair('count', 1));
    final orders = body['orders']! as List<Object?>;
    final order = orders.single! as Map<String, Object?>;
    expect(order, containsPair('id', 'ord_wholesale'));
    expect(order, containsPair('sales_channel_name', 'Wholesale'));
    expect(order, isNot(contains('sales_channel_id')));
  });

  test('order list preserves channel-less legacy rows', () async {
    final token = await harness.adminToken();
    final response = await (harness.client.get('/admin/orders?order=display_id')
          ..bearer(token))
        .send();

    response.assertOk();
    final orders =
        (response.json! as Map<String, Object?>)['orders']! as List<Object?>;
    final legacy = orders.first! as Map<String, Object?>;
    expect(legacy, containsPair('id', 'ord_legacy'));
    expect(legacy, containsPair('sales_channel_name', null));
  });

  test('order list rejects malformed sales channel identifiers', () async {
    final token = await harness.adminToken();
    final request = harness.client
        .get('/admin/orders?sales_channel_id=bad%20id')
      ..bearer(token);
    (await request.send()).assertBadRequest();
  });

  test('order export applies the same sales channel boundary', () async {
    final token = await harness.adminToken();
    final request = harness.client.get(
      '/admin/orders/export?sales_channel_id=sc_wholesale&order=display_id',
    )..bearer(token);

    final response = await request.send();

    response.assertOk();
    expect(response.body, contains('ord_wholesale'));
    expect(response.body, isNot(contains('ord_legacy')));
  });
}

Future<void> _seedOrders(AdminHarness harness) async {
  await harness.raw(r'''
INSERT INTO carts (id, region_id, email, completed_at)
VALUES
  ('cart_legacy', 'reg_eu', 'legacy@example.com',
   '2026-09-10T10:00:00.000Z'),
  ('cart_wholesale', 'reg_us', 'buyer@example.com',
   '2026-09-11T10:00:00.000Z')
''');
  await harness.raw(r'''
INSERT INTO orders
  (id, display_id, cart_id, region_id, email, currency_code, subtotal,
   shipping_total, discount_total, tax, total, placed_at, created_at,
   updated_at)
VALUES
  ('ord_legacy', 1001, 'cart_legacy', 'reg_eu', 'legacy@example.com', 'eur',
   1000, 0, 0, 0, 1000, '2026-09-10T10:00:00.000Z',
   '2026-09-10T10:00:00.000Z', '2026-09-10T10:05:00.000Z'),
  ('ord_wholesale', 1002, 'cart_wholesale', 'reg_us', 'buyer@example.com',
   'usd', 2000, 0, 0, 0, 2000, '2026-09-11T10:00:00.000Z',
   '2026-09-11T10:00:00.000Z', '2026-09-11T10:05:00.000Z')
''');
  await harness.raw(r'''
INSERT INTO order_sales_channels (order_id, sales_channel_id)
VALUES ('ord_wholesale', 'sc_wholesale')
''');
}
