import 'dart:convert';

import 'package:test/test.dart';

import 'order_detail_fixture.dart';
import 'support.dart';

void main() {
  late AdminHarness harness;

  setUp(() async {
    harness = await AdminHarness.start(seedStore: true);
    await seedOrderDetail(harness);
  });
  tearDown(() => harness.stop());

  test('create fulfillment requires the Admin route guard', () async {
    final request = harness.client.post('/admin/orders/ord_detail/fulfillments')
      ..json(_body());
    (await request.send()).assertUnauthorized();
    expect(await _fulfillmentCount(harness), 1);
  });

  test('creates fulfillment from resolved provider and proven actor', () async {
    final request = harness.client.post('/admin/orders/ord_detail/fulfillments')
      ..bearer(await harness.adminToken())
      ..json(_body());

    final response = await request.send();

    response.assertOk();
    final order = response.json! as Map<String, Object?>;
    expect(order['fulfillment_status'], 'partially_fulfilled');
    expect(order['fulfillments'], hasLength(2));
    final rows = await harness.raw(r'''
SELECT provider_id, shipping_option_id, created_by, data,
       created_at, updated_at
FROM fulfillments
WHERE order_id = 'ord_detail' AND id <> 'ful_detail'
''');
    expect(rows, hasLength(1));
    expect(rows.single.readIndex<String>(0), 'manual');
    expect(rows.single.readIndex<String>(1), 'ship_eu_standard');
    expect(rows.single.readIndex<String>(2), 'admin_1');
    expect(
      jsonDecode(rows.single.readIndex<String>(3)),
      {'service_code': 'ship_eu_standard'},
    );
    final createdAt = rows.single.readIndex<DateTime>(4).toUtc();
    expect(createdAt.isUtc, isTrue);
    expect(createdAt, isNot(DateTime.utc(2026, 9, 13, 12)));
    expect(rows.single.readIndex<DateTime>(5).toUtc(), createdAt);
  });

  test('rejects missing order and invalid commands without partial writes',
      () async {
    final token = await harness.adminToken();
    final missing = harness.client.post('/admin/orders/missing/fulfillments')
      ..bearer(token)
      ..json(_body());
    (await missing.send()).assertNotFound();

    for (final body in [
      _body(quantity: 0),
      _body(quantity: 3),
      _body(itemId: 'item_missing'),
      _body(shippingOptionId: 'ship_standard'),
      _body(locationId: 'sloc_missing'),
      {..._body(), 'shipping_option_id': null},
      _body(items: [
        {'id': 'item_shirt', 'quantity': 1},
        {'id': 'item_shirt', 'quantity': 1},
      ]),
    ]) {
      final request =
          harness.client.post('/admin/orders/ord_detail/fulfillments')
            ..bearer(token)
            ..json(body);
      (await request.send()).assertUnprocessable();
    }
    expect(await _fulfillmentCount(harness), 1);
  });

  test('concurrent commands cannot over-fulfill one order line', () async {
    final token = await harness.adminToken();
    final requests = [
      for (var index = 0; index < 2; index++)
        harness.client.post('/admin/orders/ord_detail/fulfillments')
          ..bearer(token)
          ..json(_body(quantity: 2)),
    ];

    final responses = await Future.wait([
      for (final request in requests) request.send(),
    ]);

    expect(responses.map((response) => response.statusCode),
        unorderedEquals([200, 422]));
    expect(await _fulfillmentCount(harness), 2);
    final items = await harness.raw(r'''
SELECT count(*) FROM fulfillment_items
WHERE line_item_id = 'item_shirt' AND deleted_at IS NULL
''');
    expect(items.single.readIndex<int>(0), 1);
  });

  test('requested notification fails honestly before persistence', () async {
    final token = await harness.adminToken();
    final request = harness.client.post('/admin/orders/ord_detail/fulfillments')
      ..bearer(token)
      ..json({..._body(), 'no_notification': false});

    (await request.send()).assertStatus(503);

    expect(await _fulfillmentCount(harness), 1);
  });
}

Map<String, Object?> _body({
  int quantity = 1,
  String itemId = 'item_shirt',
  String locationId = 'sloc_main',
  String shippingOptionId = 'ship_eu_standard',
  List<Map<String, Object?>>? items,
}) =>
    {
      'items': items ??
          [
            {'id': itemId, 'quantity': quantity},
          ],
      'location_id': locationId,
      'shipping_option_id': shippingOptionId,
      'no_notification': true,
    };

Future<int> _fulfillmentCount(AdminHarness harness) async {
  final rows = await harness.raw(
    "SELECT count(*) FROM fulfillments WHERE order_id = 'ord_detail'",
  );
  return rows.single.readIndex<int>(0);
}
