import 'package:dust_server/testing.dart';

import 'order_detail_fixture.dart';
import 'support.dart';

/// Captured manual payment fixture for independent refund route tests.
final class PaymentRefundScenario {
  const PaymentRefundScenario(this.harness);

  /// Migrates and seeds one captured payment plus merchant reasons.
  static Future<PaymentRefundScenario> start() async {
    final harness = await AdminHarness.start(seedStore: true);
    await seedOrderDetail(harness);
    return PaymentRefundScenario(harness);
  }

  /// Real protected app and disposable database.
  final AdminHarness harness;

  /// Sends one refund command with optional authentication override.
  Future<TestResponse> refund(
    Map<String, Object?> body, {
    bool authenticated = true,
    String? token,
  }) async {
    final request = harness.client.post('/admin/payments/pay_detail/refund')
      ..json(body);
    if (authenticated) request.bearer(token ?? await harness.adminToken());
    return request.send();
  }

  /// Returns the current order-level payment status.
  Future<String> orderPaymentStatus() async => (await harness.raw(
        "SELECT payment_status FROM orders WHERE id = 'ord_detail'",
      ))
          .single
          .readIndex<String>(0);

  /// Returns the sum of committed active refunds.
  Future<int> refundedAmount() async => (await harness.raw('''
SELECT coalesce(sum(amount), 0) FROM refunds
WHERE payment_collection_id = 'pay_detail' AND deleted_at IS NULL
''')).single.readIndex<int>(0);

  /// Returns the number of committed active refund audits.
  Future<int> refundCount() async => (await harness.raw('''
SELECT count(*) FROM refunds
WHERE payment_collection_id = 'pay_detail' AND deleted_at IS NULL
''')).single.readIndex<int>(0);

  /// Closes and deletes the disposable test state.
  Future<void> stop() => harness.stop();
}
