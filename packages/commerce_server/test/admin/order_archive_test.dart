import 'package:dust_server/testing.dart';
import 'package:test/test.dart';

import 'order_detail_fixture.dart';
import 'support.dart';

void main() {
  late _OrderArchiveScenario scenario;

  setUp(() async => scenario = await _OrderArchiveScenario.start());
  tearDown(() => scenario.stop());

  test('archival requires the Admin route guard', () async {
    (await scenario.archive(authenticated: false)).assertUnauthorized();
    expect(await scenario.status(), 'completed');
  });

  test('archives a completed order and returns its refreshed detail', () async {
    final response = await scenario.archive();

    response.assertOk();
    final body = response.json! as Map<String, Object?>;
    expect(body['id'], 'ord_detail');
    expect(body['status'], 'archived');
    expect(DateTime.parse(body['updated_at']! as String).isUtc, isTrue);
    expect(await scenario.status(), 'archived');
  });

  test('archives a canceled order without erasing its audit', () async {
    await scenario.cancel();

    (await scenario.archive()).assertOk();

    final audit = await scenario.harness.raw('''
SELECT status, canceled_at, canceled_by FROM orders WHERE id = 'ord_detail'
''');
    expect(audit.single.readIndex<String>(0), 'archived');
    expect(
      audit.single.readIndex<DateTime>(1).toUtc(),
      DateTime.utc(2026, 9, 14, 1),
    );
    expect(audit.single.readIndex<String>(2), 'admin_1');
  });

  test('pending, already archived, and missing orders are rejected', () async {
    await scenario.setStatus('pending');
    (await scenario.archive()).assertUnprocessable();
    await scenario.setStatus('completed');
    (await scenario.archive()).assertOk();
    (await scenario.archive()).assertUnprocessable();

    final request = scenario.harness.client
        .post('/admin/orders/missing/archive')
      ..bearer(await scenario.harness.adminToken());
    (await request.send()).assertNotFound();
  });
}

final class _OrderArchiveScenario {
  const _OrderArchiveScenario(this.harness);

  final AdminHarness harness;

  static Future<_OrderArchiveScenario> start() async {
    final harness = await AdminHarness.start(seedStore: true);
    await seedOrderDetail(harness);
    return _OrderArchiveScenario(harness);
  }

  Future<TestResponse> archive({bool authenticated = true}) async {
    final request = harness.client.post('/admin/orders/ord_detail/archive');
    if (authenticated) request.bearer(await harness.adminToken());
    return request.send();
  }

  Future<void> cancel() => harness.raw('''
UPDATE orders
SET status = 'canceled',
    canceled_at = '2026-09-14T01:00:00.000Z',
    canceled_by = 'admin_1'
WHERE id = 'ord_detail'
''').then((_) {});

  Future<void> setStatus(String status) => harness
      .raw("UPDATE orders SET status = '$status' WHERE id = 'ord_detail'")
      .then((_) {});

  Future<String> status() async => (await harness.raw(
        "SELECT status FROM orders WHERE id = 'ord_detail'",
      ))
          .single
          .readIndex<String>(0);

  Future<void> stop() => harness.stop();
}
