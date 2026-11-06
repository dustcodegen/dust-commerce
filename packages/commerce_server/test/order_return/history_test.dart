import 'package:commerce_server/commerce_server.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:test/test.dart';

import 'support.dart';

void main() {
  late ReturnScenario scenario;

  setUp(() async => scenario = await ReturnScenario.start());
  tearDown(() async => scenario.stop());

  test('owner lists return history newest first with bounded metadata',
      () async {
    final owned = await scenario.order();
    (await scenario.request(owned.order, owned.token).send()).assertCreated();
    (await scenario.request(owned.order, owned.token).send()).assertCreated();

    final request = scenario.client
        .get('/store/orders/${owned.order.id}/returns?limit=1&offset=0')
      ..bearer(owned.token);
    final response = await request.send();

    response.assertOk();
    expect(
      (response.json! as Map<String, Object?>).keys,
      unorderedEquals({'returns', 'count', 'limit', 'offset'}),
    );
    final page = OrderReturnListView.fromJson(
      response.json! as Map<String, Object?>,
    );
    expect(page.count, 2);
    expect(page.limit, 1);
    expect(page.offset, 0);
    expect(page.returns.single.displayId, 2);
    expect(page.returns.single.orderId, owned.order.id);
    expect(page.returns.single.status, OrderReturnStatus.requested);
  });

  test('owned order without returns has an empty history', () async {
    final owned = await scenario.order();
    final request = scenario.client
        .get('/store/orders/${owned.order.id}/returns')
      ..bearer(owned.token);

    final response = await request.send();
    response.assertOk();
    final page = OrderReturnListView.fromJson(
      response.json! as Map<String, Object?>,
    );
    expect(page.count, 0);
    expect(page.returns, isEmpty);
  });

  test('route guard rejects missing authorization', () async {
    final owned = await scenario.order();

    final response = await scenario.client
        .get('/store/orders/${owned.order.id}/returns')
        .send();

    response.assertUnauthorized();
  });

  test('missing and foreign order histories share not found', () async {
    final owned = await scenario.order();
    final stranger = await scenario.harness.account('stranger@example.com');
    final foreign = scenario.client
        .get('/store/orders/${owned.order.id}/returns')
      ..bearer(stranger.token);
    final missing = scenario.client.get('/store/orders/order_missing/returns')
      ..bearer(owned.token);

    (await foreign.send()).assertNotFound();
    (await missing.send()).assertNotFound();
  });

  test('soft-deleted returns are absent from rows and count', () async {
    final owned = await scenario.order();
    (await scenario.request(owned.order, owned.token).send()).assertCreated();
    await queryExecute(
      "UPDATE return_requests SET deleted_at = "
      r"'2026-09-14T12:00:00.000Z' WHERE order_id = $1",
      [owned.order.id],
    ).execute(scenario.harness.database.executor);
    final request = scenario.client
        .get('/store/orders/${owned.order.id}/returns')
      ..bearer(owned.token);

    final response = await request.send();
    response.assertOk();
    final page = OrderReturnListView.fromJson(
      response.json! as Map<String, Object?>,
    );
    expect(page.count, 0);
    expect(page.returns, isEmpty);
  });
}
