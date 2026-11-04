import 'dart:convert';

import 'package:test/test.dart';

import 'support.dart';

void main() {
  late AdminHarness harness;

  setUp(() async {
    harness = await AdminHarness.start(seedStore: true);
    await _seedOrders(harness);
  });
  tearDown(() => harness.stop());

  test('order list requires a proven admin bearer', () async {
    (await harness.client.get('/admin/orders').send()).assertUnauthorized();
  });

  test('order list accepts generated-client empty optional filters', () async {
    final token = await harness.adminToken();
    final request = harness.client.get(
      '/admin/orders?q=&status=&region_id=&sales_channel_id=&customer_id='
      '&created_at=&updated_at=&order=-created_at&limit=20&offset=0',
    )..bearer(token);

    final response = await request.send();

    response.assertOk();
    expect(response.json, containsPair('count', 2));
  });

  test('order list exposes a bounded newest-first merchant allowlist',
      () async {
    final token = await harness.adminToken();
    final request = harness.client.get('/admin/orders?limit=1&offset=0')
      ..bearer(token);
    final response = await request.send();

    response.assertOk();
    final json = response.json! as Map<String, Object?>;
    expect(json, containsPair('count', 2));
    expect(json, containsPair('limit', 1));
    expect(json, containsPair('offset', 0));
    final orders = json['orders']! as List<Object?>;
    expect(orders, hasLength(1));
    final order = orders.single! as Map<String, Object?>;
    expect(order.keys, {
      'country_code',
      'created_at',
      'currency_code',
      'customer_name',
      'display_id',
      'email',
      'fulfillment_status',
      'id',
      'payment_status',
      'sales_channel_name',
      'status',
      'total',
      'updated_at',
    });
    expect(order, containsPair('display_id', 1002));
    expect(order, containsPair('customer_name', 'guest@example.com'));
    expect(order, containsPair('country_code', 'us'));
    expect(order, containsPair('fulfillment_status', 'not_fulfilled'));
    expect(order, isNot(contains('cart_id')));
    expect(order, isNot(contains('metadata')));
  });

  test('order list searches and filters before stable paging', () async {
    final token = await harness.adminToken();
    final uri = Uri(path: '/admin/orders', queryParameters: {
      'q': 'ADA',
      'status': 'completed',
      'region_id': 'reg_eu',
      'created_at': jsonEncode({r'$gte': '2026-09-10T00:00:00Z'}),
      'order': 'display_id',
      'limit': '20',
    });
    final request = harness.client.get(uri.toString())..bearer(token);
    final response = await request.send();

    response.assertOk();
    final json = response.json! as Map<String, Object?>;
    expect(json, containsPair('count', 1));
    final orders = json['orders']! as List<Object?>;
    final order = orders.single! as Map<String, Object?>;
    expect(order, containsPair('id', 'ord_1001'));
    expect(order, containsPair('customer_name', 'Ada Lovelace'));
    expect(order, containsPair('payment_status', 'captured'));
    expect(order, containsPair('total', 2500));
    expect(order, containsPair('currency_code', 'eur'));
    expect(order, containsPair('country_code', 'dk'));
  });

  test('order list scopes order history to one customer id', () async {
    final request = harness.client.get(
      '/admin/orders?customer_id=cus_ada&limit=10',
    )..bearer(await harness.adminToken());

    final response = await request.send();

    response.assertOk();
    final json = response.json! as Map<String, Object?>;
    expect(json, containsPair('count', 1));
    final orders = json['orders']! as List<Object?>;
    expect(orders.single, containsPair('id', 'ord_1001'));
  });

  test('order list rejects filters and order keys outside its allowlist',
      () async {
    final token = await harness.adminToken();
    for (final query in [
      'status=deleted',
      'order=total',
      'region_id=bad%20id',
      'customer_id=bad%20id',
      'created_at=tomorrow',
    ]) {
      final request = harness.client.get('/admin/orders?$query')..bearer(token);
      (await request.send()).assertBadRequest();
    }
  });
}

Future<void> _seedOrders(AdminHarness harness) async {
  await harness.raw(r'''
INSERT INTO customers (id, email, first_name, last_name, has_account)
VALUES ('cus_ada', 'ada@example.com', 'Ada', 'Lovelace', 1)
''');
  await harness.raw(r'''
INSERT INTO carts (id, region_id, customer_id, email, completed_at)
VALUES
  ('cart_1001', 'reg_eu', 'cus_ada', 'ada@example.com',
   '2026-09-10T10:00:00.000Z'),
  ('cart_1002', 'reg_us', NULL, 'guest@example.com',
   '2026-09-11T10:00:00.000Z')
''');
  await harness.raw(r'''
INSERT INTO orders
  (id, display_id, cart_id, region_id, customer_id, email, currency_code,
   subtotal, shipping_total, discount_total, tax, total, status,
   payment_status, placed_at, created_at, updated_at)
VALUES
  ('ord_1001', 1001, 'cart_1001', 'reg_eu', 'cus_ada', 'ada@example.com',
   'eur', 2300, 200, 0, 0, 2500, 'completed', 'captured',
   '2026-09-10T10:00:00.000Z', '2026-09-10T10:00:00.000Z',
   '2026-09-10T10:05:00.000Z'),
  ('ord_1002', 1002, 'cart_1002', 'reg_us', NULL, 'guest@example.com',
   'usd', 1500, 0, 0, 0, 1500, 'pending', 'awaiting',
   '2026-09-11T10:00:00.000Z', '2026-09-11T10:00:00.000Z',
   '2026-09-11T10:05:00.000Z')
''');
  await harness.raw(r'''
INSERT INTO order_addresses
  (order_id, kind, first_name, last_name, line1, city, postal_code,
   country_code)
VALUES
  ('ord_1001', 'shipping', 'Ada', 'Lovelace', '1 Harbour Way',
   'Copenhagen', '1050', 'dk'),
  ('ord_1002', 'shipping', 'Guest', 'Buyer', '1 Main Street',
   'New York', '10001', 'us')
''');
}
