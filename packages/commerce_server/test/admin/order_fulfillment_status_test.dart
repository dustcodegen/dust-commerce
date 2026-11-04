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

  test('derives Medusa fulfillment status from active quantities', () async {
    final token = await harness.adminToken();
    expect(await _status(harness, token), 'partially_fulfilled');

    await harness.raw(r'''
INSERT INTO fulfillments
  (id, order_id, location_id, provider_id, shipping_option_id,
   requires_shipping, created_by, created_at, updated_at)
VALUES
  ('ful_detail_two', 'ord_detail', 'sloc_main', 'manual', 'ship_eu_standard',
   1, 'admin_1', '2026-09-10T10:04:00.000Z',
   '2026-09-10T10:04:00.000Z')
''');
    await harness.raw(r'''
INSERT INTO fulfillment_items
  (id, fulfillment_id, title, quantity, sku, barcode, line_item_id)
VALUES
  ('fulitem_detail_two', 'ful_detail_two', 'T-shirt', 2,
   'TSHIRT-M-BLACK', '', 'item_shirt')
''');
    expect(await _status(harness, token), 'fulfilled');

    await harness.raw("UPDATE fulfillments SET shipped_at = "
        "'2026-09-10T11:00:00.000Z' WHERE id = 'ful_detail'");
    expect(await _status(harness, token), 'partially_shipped');

    await harness.raw("UPDATE fulfillments SET shipped_at = "
        "'2026-09-10T11:01:00.000Z' WHERE id = 'ful_detail_two'");
    expect(await _status(harness, token), 'shipped');

    await harness.raw("UPDATE fulfillments SET delivered_at = "
        "'2026-09-10T12:00:00.000Z' WHERE id = 'ful_detail'");
    expect(await _status(harness, token), 'partially_delivered');

    await harness.raw("UPDATE fulfillments SET delivered_at = "
        "'2026-09-10T12:01:00.000Z' WHERE id = 'ful_detail_two'");
    expect(await _status(harness, token), 'delivered');
  });
}

Future<String> _status(AdminHarness harness, String token) async {
  final request = harness.client.get('/admin/orders/ord_detail')..bearer(token);
  final response = await request.send();
  response.assertOk();
  return (response.json! as Map<String, Object?>)['fulfillment_status']!
      as String;
}
