import 'package:commerce_server/commerce_server.dart';
import 'package:dust_server/testing.dart';
import 'package:test/test.dart';

import 'order_cancellation_support.dart';

void main() {
  late OrderCancellationScenario scenario;

  setUp(() async => scenario = await OrderCancellationScenario.start());
  tearDown(() => scenario.stop());

  test('a waiting partial refund sees the previously committed amount',
      () async {
    final response = await _afterConcurrentRefund(scenario, (token) {
      return (scenario.harness.client.post('/admin/payments/pay_detail/refund')
            ..bearer(token)
            ..json({'amount': 3500}))
          .send();
    });

    response.assertStatus(422);
    expect(await scenario.refundCount(), 1);
    expect(await _refundedAmount(scenario), 3500);
  });

  test('a waiting cancellation refunds only the newly committed remainder',
      () async {
    final response = await _afterConcurrentRefund(
      scenario,
      (token) => scenario.cancel(token: token),
    );

    response.assertOk();
    expect(await scenario.refundCount(), 2);
    expect(await _refundedAmount(scenario), 5400);
    expect(await scenario.stock(), scenario.stockBeforeOrder);
  });
}

/// Holds an uncommitted partial refund on a separate database connection.
Future<TestResponse> _afterConcurrentRefund(
  OrderCancellationScenario scenario,
  Future<TestResponse> Function(String token) send,
) async {
  final harness = scenario.harness;
  final token = await harness.adminToken();
  late Future<TestResponse> response;
  final transaction = await harness.database.transaction<Unit>((tx) async {
    final owner = (await queryRaw('''
SELECT pg_backend_pid() FROM orders WHERE id = 'ord_detail' FOR UPDATE
''', []).fetch(tx)).single.readIndex<int>(0);
    await queryRaw('''
INSERT INTO refunds (id, payment_collection_id, amount, currency_code, created_by)
VALUES ('prior_partial_refund', 'pay_detail', 3500, 'eur', 'admin_1')
RETURNING id
''', []).fetch(tx);

    response = send(token);
    // Wait for PostgreSQL to report contention before publishing the refund.
    final deadline = Stopwatch()..start();
    while (deadline.elapsed < const Duration(seconds: 5)) {
      final waiting = (await queryRaw(r'''
SELECT EXISTS (
  SELECT 1 FROM pg_stat_activity
  WHERE datname = current_database() AND $1::int = ANY(pg_blocking_pids(pid))
)
''', [owner]).fetch(harness.database.executor)).single.readIndex<bool>(0);
      if (waiting) return const Ok(unit);
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    fail('The admin request never waited for the other transaction');
  });
  expect(transaction, isA<Ok<Unit, SqlxError>>());
  return response;
}

Future<int> _refundedAmount(OrderCancellationScenario scenario) async =>
    (await scenario.harness.raw('''
SELECT coalesce(sum(amount), 0) FROM refunds
WHERE payment_collection_id = 'pay_detail' AND deleted_at IS NULL
''')).single.readIndex<int>(0);
