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

  test('cancel fulfillment requires the Admin route guard', () async {
    final request = harness.client.post(_path)..json(_body);

    (await request.send()).assertUnauthorized();
    expect(await _hasCancellation(harness), isFalse);
  });

  test('cancels a pending fulfillment with database time and actor', () async {
    final request = harness.client.post(_path)
      ..bearer(await harness.adminToken())
      ..json(_body);

    final response = await request.send();

    response.assertOk();
    final order = response.json! as Map<String, Object?>;
    expect(order['fulfillment_status'], 'not_fulfilled');
    final fulfillment = (order['fulfillments']! as List<Object?>).single!
        as Map<String, Object?>;
    expect(DateTime.parse(fulfillment['canceled_at']! as String).isUtc, isTrue);
    expect(fulfillment['shipped_at'], isNull);
    expect(fulfillment['delivered_at'], isNull);
    expect(await _canceledBy(harness), 'admin_1');
    expect((await _canceledAt(harness)).isUtc, isTrue);
  });

  test('rejects unavailable notification before cancellation writes', () async {
    final request = harness.client.post(_path)
      ..bearer(await harness.adminToken())
      ..json(<String, Object?>{});

    (await request.send()).assertStatus(503);
    expect(await _hasCancellation(harness), isFalse);
  });

  test('hides missing or foreign fulfillment ownership', () async {
    final token = await harness.adminToken();
    for (final path in [
      '/admin/orders/missing/fulfillments/ful_detail/cancel',
      '/admin/orders/ord_detail/fulfillments/missing/cancel',
    ]) {
      final request = harness.client.post(path)
        ..bearer(token)
        ..json(_body);
      (await request.send()).assertNotFound();
    }
    expect(await _hasCancellation(harness), isFalse);
  });

  test('refuses a provider without a cancellation adapter', () async {
    await harness.raw("UPDATE fulfillments SET provider_id = 'external' "
        "WHERE id = 'ful_detail'");
    final request = harness.client.post(_path)
      ..bearer(await harness.adminToken())
      ..json(_body);

    (await request.send()).assertStatus(503);
    expect(await _hasCancellation(harness), isFalse);
  });

  test('rejects shipped, delivered and repeated cancellation', () async {
    final token = await harness.adminToken();
    for (final column in ['shipped_at', 'delivered_at']) {
      await harness.raw("UPDATE fulfillments SET $column = "
          "'2026-09-10T11:00:00.000Z' WHERE id = 'ful_detail'");
      final request = harness.client.post(_path)
        ..bearer(token)
        ..json(_body);
      (await request.send()).assertUnprocessable();
      await harness.raw(
          "UPDATE fulfillments SET $column = NULL WHERE id = 'ful_detail'");
    }

    final first = harness.client.post(_path)
      ..bearer(token)
      ..json(_body);
    (await first.send()).assertOk();
    final original = await _canceledAt(harness);
    final repeated = harness.client.post(_path)
      ..bearer(token)
      ..json(_body);
    (await repeated.send()).assertUnprocessable();
    expect(await _canceledAt(harness), original);
  });
}

const _path = '/admin/orders/ord_detail/fulfillments/ful_detail/cancel';
const _body = <String, Object?>{'no_notification': true};

Future<DateTime> _canceledAt(AdminHarness harness) async {
  final rows = await harness.raw(
    "SELECT canceled_at FROM fulfillments "
    "WHERE id = 'ful_detail' AND canceled_at IS NOT NULL",
  );
  return rows.single.readIndex<DateTime>(0).toUtc();
}

Future<String> _canceledBy(AdminHarness harness) async {
  final rows = await harness.raw(
    "SELECT canceled_by FROM fulfillments "
    "WHERE id = 'ful_detail' AND canceled_by IS NOT NULL",
  );
  return rows.single.readIndex<String>(0);
}

Future<bool> _hasCancellation(AdminHarness harness) async {
  final rows = await harness.raw(
    "SELECT COUNT(*) FROM fulfillments "
    "WHERE id = 'ful_detail' AND canceled_at IS NOT NULL",
  );
  return rows.single.readIndex<int>(0) == 1;
}
