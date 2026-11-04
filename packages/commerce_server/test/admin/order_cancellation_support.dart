import 'package:dust_server/testing.dart';

import 'order_detail_fixture.dart';
import 'support.dart';

final class OrderCancellationScenario {
  const OrderCancellationScenario(this.harness, this.stockBeforeOrder);

  final AdminHarness harness;
  final Map<String, int> stockBeforeOrder;

  static Future<OrderCancellationScenario> start() async {
    final harness = await AdminHarness.start(seedStore: true);
    await seedOrderDetail(harness);
    await harness.raw('''
UPDATE orders SET status = 'pending' WHERE id = 'ord_detail'
''');
    await harness.raw('''
UPDATE fulfillments
SET canceled_at = '2026-09-14T01:00:00.000Z', canceled_by = 'admin_1'
WHERE id = 'ful_detail'
''');
    final stockBeforeOrder = await _stock(harness);
    await harness.raw('''
UPDATE product_variants
SET manage_inventory = 1,
    inventory_quantity = inventory_quantity - CASE id
      WHEN 'var_cup' THEN 1 WHEN 'var_shirt_m' THEN 2 ELSE 0 END
WHERE id IN ('var_cup', 'var_shirt_m')
''');
    return OrderCancellationScenario(harness, stockBeforeOrder);
  }

  Future<void> stop() => harness.stop();

  Future<TestResponse> cancel(
      {bool authenticated = true, String? token}) async {
    final request = harness.client.post('/admin/orders/ord_detail/cancel');
    if (authenticated) request.bearer(token ?? await harness.adminToken());
    return request.send();
  }

  Future<void> makeUnpaid() async {
    await harness.raw('''
UPDATE orders SET payment_status = 'awaiting' WHERE id = 'ord_detail'
''');
    await harness.raw('''
UPDATE payment_collections
SET status = 'authorized', captured_at = NULL WHERE id = 'pay_detail'
''');
  }

  Future<void> activateFulfillment() async {
    await harness.raw('''
UPDATE fulfillments SET canceled_at = NULL, canceled_by = NULL
WHERE id = 'ful_detail'
''');
  }

  Future<void> completeOrder() async {
    await harness.raw('''
UPDATE orders SET status = 'completed' WHERE id = 'ord_detail'
''');
  }

  Future<Map<String, int>> stock() => _stock(harness);

  Future<String> orderStatus() async => (await harness.raw(
        "SELECT status FROM orders WHERE id = 'ord_detail'",
      ))
          .single
          .readIndex<String>(0);

  Future<int> refundCount() async => (await harness.raw(
        "SELECT count(*) FROM refunds WHERE payment_collection_id = 'pay_detail'",
      ))
          .single
          .readIndex<int>(0);
}

Future<Map<String, int>> _stock(AdminHarness harness) async {
  final rows = await harness.raw('''
SELECT id, inventory_quantity FROM product_variants
WHERE id IN ('var_cup', 'var_shirt_m') ORDER BY id
''');
  return {
    for (final row in rows) row.readIndex<String>(0): row.readIndex<int>(1)
  };
}
