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

  test('mark delivered requires the Admin route guard', () async {
    final request = harness.client.post(_path)..json(_body);

    (await request.send()).assertUnauthorized();
    expect(await _hasDeliveredAt(harness), isFalse);
  });

  test('marks an active fulfillment delivered using database time', () async {
    final request = harness.client.post(_path)
      ..bearer(await harness.adminToken())
      ..json(_body);

    final response = await request.send();

    response.assertOk();
    final order = response.json! as Map<String, Object?>;
    expect(order['fulfillment_status'], 'partially_delivered');
    final fulfillment = (order['fulfillments']! as List<Object?>).single!
        as Map<String, Object?>;
    expect(
        DateTime.parse(fulfillment['delivered_at']! as String).isUtc, isTrue);
    expect(fulfillment['shipped_at'], isNull);
    expect((await _deliveredAt(harness)).isUtc, isTrue);
  });

  test('rejects unavailable notification before delivery writes', () async {
    final request = harness.client.post(_path)
      ..bearer(await harness.adminToken())
      ..json(<String, Object?>{});

    (await request.send()).assertStatus(503);
    expect(await _hasDeliveredAt(harness), isFalse);
  });

  test('hides missing or foreign fulfillment ownership', () async {
    final token = await harness.adminToken();
    for (final path in [
      '/admin/orders/missing/fulfillments/ful_detail/mark-as-delivered',
      '/admin/orders/ord_detail/fulfillments/missing/mark-as-delivered',
    ]) {
      final request = harness.client.post(path)
        ..bearer(token)
        ..json(_body);
      (await request.send()).assertNotFound();
    }
    expect(await _hasDeliveredAt(harness), isFalse);
  });

  test('rejects canceled and repeated delivery without rewriting time',
      () async {
    final token = await harness.adminToken();
    await harness.raw(r'''
UPDATE fulfillments SET canceled_at = '2026-09-10T11:00:00.000Z'
WHERE id = 'ful_detail'
''');
    final canceled = harness.client.post(_path)
      ..bearer(token)
      ..json(_body);
    (await canceled.send()).assertUnprocessable();

    await harness.raw(r'''
UPDATE fulfillments SET canceled_at = NULL WHERE id = 'ful_detail'
''');
    final first = harness.client.post(_path)
      ..bearer(token)
      ..json(_body);
    (await first.send()).assertOk();
    final original = await _deliveredAt(harness);
    final repeated = harness.client.post(_path)
      ..bearer(token)
      ..json(_body);
    (await repeated.send()).assertUnprocessable();
    expect(await _deliveredAt(harness), original);
  });
}

const _path =
    '/admin/orders/ord_detail/fulfillments/ful_detail/mark-as-delivered';
const _body = <String, Object?>{'no_notification': true};

Future<DateTime> _deliveredAt(AdminHarness harness) async {
  final rows = await harness.raw(
    "SELECT delivered_at FROM fulfillments "
    "WHERE id = 'ful_detail' AND delivered_at IS NOT NULL",
  );
  return rows.single.readIndex<DateTime>(0).toUtc();
}

Future<bool> _hasDeliveredAt(AdminHarness harness) async {
  final rows = await harness.raw(
    "SELECT COUNT(*) FROM fulfillments "
    "WHERE id = 'ful_detail' AND delivered_at IS NOT NULL",
  );
  return rows.single.readIndex<int>(0) == 1;
}
