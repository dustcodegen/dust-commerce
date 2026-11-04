import 'package:commerce_server/commerce_server.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:test/test.dart';

import 'support.dart';

void main() {
  late CheckoutHarness harness;

  setUp(() async => harness = await CheckoutHarness.start());
  tearDown(() => harness.stop());

  test('Store order derives fulfillment progress and delivered units',
      () async {
    final account = await harness.account('owner@example.com');
    final cart = await harness.cartWith(
      'var_small',
      quantity: 3,
      token: account.token,
    );
    final placed = await harness.checkout(cart, token: account.token);
    placed.assertCreated();
    final order = Order.fromJson(placed.json! as Map<String, Object?>);

    expect(order.fulfillmentStatus, OrderFulfillmentStatus.notFulfilled);
    expect(order.items.single.detail.deliveredQuantity, 0);

    await _fulfill(harness, order, 'first', 1);
    expect(
      await _read(harness, account.token, order.id),
      isA<Order>().having(
        (value) => value.fulfillmentStatus,
        'status',
        OrderFulfillmentStatus.partiallyFulfilled,
      ),
    );

    await _event(harness, 'first', 'shipped_at');
    final shipped = await _read(harness, account.token, order.id);
    expect(shipped.fulfillmentStatus, OrderFulfillmentStatus.partiallyShipped);
    expect(shipped.items.single.detail.deliveredQuantity, 0);

    await _event(harness, 'first', 'delivered_at');
    final partiallyDelivered = await _read(harness, account.token, order.id);
    expect(
      partiallyDelivered.fulfillmentStatus,
      OrderFulfillmentStatus.partiallyDelivered,
    );
    expect(partiallyDelivered.items.single.detail.deliveredQuantity, 1);

    await _fulfill(harness, order, 'second', 2, delivered: true);
    final delivered = await _read(harness, account.token, order.id);
    expect(delivered.fulfillmentStatus, OrderFulfillmentStatus.delivered);
    expect(delivered.items.single.detail.deliveredQuantity, 3);

    final listRequest = harness.client.get('/store/orders')
      ..bearer(account.token);
    final listed = OrderListView.fromJson(
      (await listRequest.send()).json! as Map<String, Object?>,
    );
    expect(listed.orders.single.fulfillmentStatus, delivered.fulfillmentStatus);
  });
}

Future<Order> _read(CheckoutHarness harness, String token, String id) async {
  final request = harness.client.get('/store/orders/$id')..bearer(token);
  final response = await request.send();
  response.assertOk();
  return Order.fromJson(response.json! as Map<String, Object?>);
}

Future<void> _fulfill(
  CheckoutHarness harness,
  Order order,
  String suffix,
  int quantity, {
  bool delivered = false,
}) async {
  await queryExecute(
    'INSERT INTO fulfillments '
    '(id, order_id, location_id, provider_id, delivered_at) '
    'VALUES (\$1, \$2, \$3, \$4, \$5)',
    [
      'ful_$suffix',
      order.id,
      'location_test',
      'manual',
      delivered ? '2100-01-01T12:00:00.000Z' : null,
    ],
  ).execute(harness.database.executor);
  await queryExecute(
    'INSERT INTO fulfillment_items '
    '(id, fulfillment_id, title, quantity, sku, barcode, line_item_id) '
    "VALUES (\$1, \$2, \$3, \$4, '', '', \$5)",
    [
      'fulitem_$suffix',
      'ful_$suffix',
      order.items.single.title,
      quantity,
      order.items.single.id,
    ],
  ).execute(harness.database.executor);
}

Future<void> _event(
  CheckoutHarness harness,
  String suffix,
  String column,
) =>
    queryExecute(
      'UPDATE fulfillments SET $column = \$1 WHERE id = \$2',
      ['2100-01-01T12:00:00.000Z', 'ful_$suffix'],
    ).execute(harness.database.executor);
