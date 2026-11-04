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

  test('create shipment requires the Admin route guard', () async {
    final request = harness.client.post(_path)..json(_body());

    (await request.send()).assertUnauthorized();
    expect(await _shipmentCount(harness), 0);
  });

  test('marks the exact fulfillment items shipped with safe labels', () async {
    final request = harness.client.post(_path)
      ..bearer(await harness.adminToken())
      ..json(_body(labels: [_existingLabel, _newLabel]));

    final response = await request.send();

    response.assertOk();
    final order = response.json! as Map<String, Object?>;
    expect(order['fulfillment_status'], 'partially_shipped');
    final fulfillment = (order['fulfillments']! as List<Object?>).single!
        as Map<String, Object?>;
    expect(fulfillment['marked_shipped_by'], 'admin_1');
    expect(DateTime.parse(fulfillment['shipped_at']! as String).isUtc, isTrue);
    final labels = fulfillment['labels']! as List<Object?>;
    expect(labels, hasLength(2));
    expect(
      labels
          .map((label) => (label! as Map<String, Object?>)['tracking_number']),
      ['TRACK-123', 'TRACK-NEW'],
    );
    expect(await _shipmentCount(harness), 1);
  });

  test('rejects wrong items and unsafe links without partial writes', () async {
    final token = await harness.adminToken();
    for (final body in <Map<String, Object?>>[
      _body(items: <Map<String, Object?>>[]),
      _body(items: [
        {'id': 'item_cup', 'quantity': 2},
      ]),
      _body(items: [
        {'id': 'item_missing', 'quantity': 1},
      ]),
      _body(labels: [
        {
          'tracking_number': 'TRACK-NEW',
          'tracking_url': 'javascript:alert(1)',
          'label_url': '#',
        },
      ]),
    ]) {
      final request = harness.client.post(_path)
        ..bearer(token)
        ..json(body);
      (await request.send()).assertUnprocessable();
    }

    expect(await _shipmentCount(harness), 0);
  });

  test('hides missing or foreign fulfillment ownership', () async {
    final token = await harness.adminToken();
    for (final path in [
      '/admin/orders/missing/fulfillments/ful_detail/shipments',
      '/admin/orders/ord_detail/fulfillments/ful_missing/shipments',
    ]) {
      final request = harness.client.post(path)
        ..bearer(token)
        ..json(_body());
      (await request.send()).assertNotFound();
    }
    expect(await _shipmentCount(harness), 0);
  });

  test('rejects repeat and unavailable notification honestly', () async {
    final token = await harness.adminToken();
    final notify = harness.client.post(_path)
      ..bearer(token)
      ..json({..._body(), 'no_notification': false});
    (await notify.send()).assertStatus(503);

    final first = harness.client.post(_path)
      ..bearer(token)
      ..json(_body());
    (await first.send()).assertOk();
    final repeated = harness.client.post(_path)
      ..bearer(token)
      ..json(_body());
    (await repeated.send()).assertUnprocessable();
    expect(await _shipmentCount(harness), 1);
  });
}

const _path = '/admin/orders/ord_detail/fulfillments/ful_detail/shipments';

Map<String, Object?> _body({
  List<Map<String, Object?>>? items,
  List<Map<String, Object?>>? labels,
}) =>
    {
      'items': items ??
          [
            {'id': 'item_cup', 'quantity': 1},
          ],
      'labels': labels ?? [_newLabel],
      'no_notification': true,
    };

const _existingLabel = <String, Object?>{
  'tracking_number': 'TRACK-123',
  'tracking_url': 'https://carrier.example/TRACK-123',
  'label_url': '#',
};

const _newLabel = <String, Object?>{
  'tracking_number': 'TRACK-NEW',
  'tracking_url': 'https://carrier.example/TRACK-NEW',
  'label_url': '#',
};

Future<int> _shipmentCount(AdminHarness harness) async {
  final rows = await harness.raw(r'''
SELECT count(*) FROM fulfillment_labels
WHERE fulfillment_id = 'ful_detail' AND tracking_number = 'TRACK-NEW'
''');
  return rows.single.readIndex<int>(0);
}
