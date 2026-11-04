import 'package:commerce_server/commerce_server.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:test/test.dart';

import 'support.dart';

void main() {
  late ReturnScenario scenario;

  setUp(() async => scenario = await ReturnScenario.start());
  tearDown(() async => scenario.stop());

  test('authenticated owner requests a return for frozen order items',
      () async {
    final owned = await scenario.order();

    final response = await scenario.request(owned.order, owned.token).send();

    response.assertCreated();
    expect(
      (response.json! as Map<String, Object?>).keys,
      unorderedEquals(<String>{
        'id',
        'display_id',
        'order_id',
        'status',
        'item_quantity',
        'requested_at',
      }),
    );
    final returned = OrderReturnView.fromJson(
      response.json! as Map<String, Object?>,
    );
    expect(returned.orderId, owned.order.id);
    expect(returned.displayId, 1);
    expect(returned.itemQuantity, 1);
    expect(returned.status, OrderReturnStatus.requested);
    expect(returned.requestedAt.isUtc, isTrue);
  });

  test('route guard rejects a request without bearer authorization', () async {
    final owned = await scenario.order();
    final request = scenario.client.post('/store/returns')
      ..json(OrderReturnRequestBody(
        orderId: owned.order.id,
        items: [
          OrderReturnItemInput(
            itemId: owned.order.items.single.id,
            quantity: 1,
          ),
        ],
      ).toJson());

    (await request.send()).assertUnauthorized();
  });

  test('missing and foreign orders share the same unavailable response',
      () async {
    final owned = await scenario.order();
    final stranger = await scenario.harness.account('stranger@example.com');
    final foreign = scenario.request(owned.order, stranger.token);
    final missing = scenario.client.post('/store/returns')
      ..bearer(owned.token)
      ..json({
        'order_id': 'order_missing',
        'items': [
          {'id': owned.order.items.single.id, 'quantity': 1},
        ],
      });

    (await foreign.send()).assertNotFound();
    (await missing.send()).assertNotFound();
  });

  test('undelivered items cannot enter the return lifecycle', () async {
    final owned = await scenario.order(deliver: false);

    (await scenario.request(owned.order, owned.token).send())
        .assertUnprocessable();
  });

  test('uncaptured orders cannot enter the return lifecycle', () async {
    final owned = await scenario.order(capture: false, deliver: false);

    (await scenario.request(owned.order, owned.token).send())
        .assertUnprocessable();
  });

  test('invalid item, reason and quantity leave no partial request', () async {
    final owned = await scenario.order();

    (await scenario
            .request(owned.order, owned.token, itemId: 'item_missing')
            .send())
        .assertUnprocessable();
    (await scenario
            .request(owned.order, owned.token, reasonId: 'reason_missing')
            .send())
        .assertUnprocessable();
    (await scenario.request(owned.order, owned.token, quantity: 4).send())
        .assertUnprocessable();

    final rows = await queryRaw('SELECT COUNT(*) FROM return_requests', [])
        .fetch(scenario.harness.database.connection as Executor);
    expect(rows.single.readIndex<int>(0), 0);
  });

  test('active requests cannot exceed the quantity delivered', () async {
    final owned = await scenario.order();
    (await scenario.request(owned.order, owned.token, quantity: 2).send())
        .assertCreated();

    (await scenario.request(owned.order, owned.token, quantity: 2).send())
        .assertUnprocessable();
  });

  test('owned order detail reports quantities reserved by active returns',
      () async {
    final owned = await scenario.order();
    expect(owned.order.items.single.detail.deliveredQuantity, 3);
    (await scenario.request(owned.order, owned.token, quantity: 2).send())
        .assertCreated();

    final request = scenario.client.get('/store/orders/${owned.order.id}')
      ..bearer(owned.token);
    final response = await request.send();
    response.assertOk();
    final order = Order.fromJson(response.json! as Map<String, Object?>);

    expect(order.items.single.detail.deliveredQuantity, 3);
    expect(order.items.single.detail.returnRequestedQuantity, 2);
    expect(order.items.single.detail.returnReceivedQuantity, 0);
    expect(order.items.single.detail.returnDismissedQuantity, 0);
    expect(order.items.single.detail.returnableQuantity, 1);
  });

  test('concurrent requests receive distinct monotonic display numbers',
      () async {
    final first = await scenario.order(email: 'first@example.com');
    final second = await scenario.order(email: 'second@example.com');

    final responses = await Future.wait([
      scenario.request(first.order, first.token).send(),
      scenario.request(second.order, second.token).send(),
    ]);

    for (final response in responses) {
      response.assertCreated();
    }
    final ids = responses
        .map((response) => OrderReturnView.fromJson(
              response.json! as Map<String, Object?>,
            ).displayId)
        .toSet();
    expect(ids, {1, 2});
  });
}
