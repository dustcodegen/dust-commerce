import 'package:dust_server/testing.dart';
import 'package:test/test.dart';

import 'order_detail_fixture.dart';
import 'support.dart';

void main() {
  late _OrderCompletionScenario scenario;

  setUp(() async => scenario = await _OrderCompletionScenario.start());
  tearDown(() => scenario.stop());

  test('completion requires the Admin route guard', () async {
    (await scenario.complete(authenticated: false)).assertUnauthorized();
    expect(await scenario.status(), 'pending');
  });

  test('completes a pending order without inventing payment rules', () async {
    await scenario.awaitPayment();

    final response = await scenario.complete();

    response.assertOk();
    final body = response.json! as Map<String, Object?>;
    expect(body['status'], 'completed');
    expect(body['payment_status'], 'awaiting');
    expect(body['fulfillment_status'], 'partially_fulfilled');
    expect((await scenario.updatedAt()).isUtc, isTrue);
  });

  test('completion is idempotent for an already completed order', () async {
    (await scenario.complete()).assertOk();
    (await scenario.complete()).assertOk();
    expect(await scenario.status(), 'completed');
  });

  test('canceled and missing orders cannot be completed', () async {
    await scenario.cancelOrder();
    (await scenario.complete()).assertUnprocessable();
    expect(await scenario.status(), 'canceled');

    final request = scenario.harness.client
        .post('/admin/orders/missing/complete')
      ..bearer(await scenario.harness.adminToken());
    (await request.send()).assertNotFound();
  });
}

final class _OrderCompletionScenario {
  const _OrderCompletionScenario(this.harness);

  final AdminHarness harness;

  static Future<_OrderCompletionScenario> start() async {
    final harness = await AdminHarness.start(seedStore: true);
    await seedOrderDetail(harness);
    await harness
        .raw("UPDATE orders SET status = 'pending' WHERE id = 'ord_detail'");
    return _OrderCompletionScenario(harness);
  }

  Future<void> stop() => harness.stop();

  Future<TestResponse> complete({bool authenticated = true}) async {
    final request = harness.client.post('/admin/orders/ord_detail/complete');
    if (authenticated) request.bearer(await harness.adminToken());
    return request.send();
  }

  Future<void> awaitPayment() async {
    await harness.raw('''
UPDATE orders SET payment_status = 'awaiting' WHERE id = 'ord_detail'
''');
    await harness.raw('''
UPDATE payment_collections
SET status = 'authorized', captured_at = NULL WHERE id = 'pay_detail'
''');
  }

  Future<void> cancelOrder() async {
    await harness.raw('''
UPDATE orders
SET status = 'canceled', canceled_at = '2026-09-14T01:00:00.000Z'
WHERE id = 'ord_detail'
''');
  }

  Future<String> status() async => (await harness.raw(
        "SELECT status FROM orders WHERE id = 'ord_detail'",
      ))
          .single
          .readIndex<String>(0);

  Future<DateTime> updatedAt() async => (await harness.raw(
        "SELECT updated_at FROM orders WHERE id = 'ord_detail'",
      ))
          .single
          .readIndex<DateTime>(0)
          .toUtc();
}
