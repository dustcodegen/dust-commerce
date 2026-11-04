import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:test/test.dart';

import 'order_detail_fixture.dart';
import 'return_fixture.dart';
import 'support.dart';

void main() {
  late AdminHarness harness;

  setUp(() async {
    harness = await AdminHarness.start(seedStore: true);
    await seedOrderDetail(harness);
    await seedAdminReturns(harness);
  });
  tearDown(() => harness.stop());

  test('return list requires a proven admin bearer', () async {
    (await harness.client.get('/admin/returns').send()).assertUnauthorized();
  });

  test('lists requested order returns as a bounded allowlist', () async {
    final request = harness.client.get(
      '/admin/returns?order_id=ord_detail&status=requested&limit=20&offset=0',
    )..bearer(await harness.adminToken());

    final response = await request.send();

    response.assertOk();
    final page = AdminReturnList.fromJson(
      response.json! as Map<String, Object?>,
    );
    expect(page.count, 1);
    expect(page.returns.single.id, 'ret_requested');
    expect(page.returns.single.status, AdminReturnStatus.requested);
    expect(page.returns.single.requestedAt.isUtc, isTrue);
    expect(page.returns.single.items, hasLength(2));
    expect(page.returns.single.items.last.quantity, 2);
    expect(response.body, isNot(contains('customer_id')));
    expect(response.body, isNot(contains('metadata')));
  });

  test('filters lifecycle and rejects unsupported query values', () async {
    final token = await harness.adminToken();
    final received = harness.client.get(
      '/admin/returns?order_id=ord_detail&status=received',
    )..bearer(token);

    final response = await received.send();

    response.assertOk();
    final page = AdminReturnList.fromJson(
      response.json! as Map<String, Object?>,
    );
    expect(page.returns.single.id, 'ret_received');
    expect(page.returns.single.items.single.receivedQuantity, 1);

    for (final query in ['status=open', 'order_id=bad%20id']) {
      final request = harness.client.get('/admin/returns?$query')
        ..bearer(token);
      (await request.send()).assertBadRequest();
    }
  });
}
