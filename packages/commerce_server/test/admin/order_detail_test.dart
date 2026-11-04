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

  test('order detail requires a proven admin bearer', () async {
    (await harness.client.get('/admin/orders/ord_detail').send())
        .assertUnauthorized();
  });

  test('order detail returns the complete merchant allowlist', () async {
    final request = harness.client.get('/admin/orders/ord_detail')
      ..bearer(await harness.adminToken());

    final response = await request.send();

    response.assertOk();
    final order = response.json! as Map<String, Object?>;
    expect(order.keys, {
      'billing_address',
      'created_at',
      'currency_code',
      'customer_name',
      'discount_total',
      'display_id',
      'email',
      'fulfillment_status',
      'fulfillments',
      'id',
      'items',
      'payment_amount',
      'payment_captured_at',
      'payment_created_at',
      'payment_id',
      'payment_provider',
      'payment_record_status',
      'payment_refunded_amount',
      'payment_refunds',
      'payment_status',
      'placed_at',
      'promotion_code',
      'region_id',
      'shipping_address',
      'shipping_name',
      'shipping_option_id',
      'shipping_total',
      'status',
      'subtotal',
      'tax',
      'total',
      'updated_at',
    });
    expect(order, containsPair('customer_name', 'Ada Lovelace'));
    expect(order, containsPair('total', 5400));
    expect(order, containsPair('payment_provider', 'manual'));
    expect(order, containsPair('payment_id', 'pay_detail'));
    expect(order, containsPair('payment_refunded_amount', 0));
    expect(order, containsPair('payment_refunds', isEmpty));
    expect(order, containsPair('payment_record_status', 'captured'));
    expect(order, containsPair('region_id', 'reg_eu'));
    expect(order, containsPair('shipping_option_id', 'so_standard'));
    expect(order, containsPair('fulfillment_status', 'partially_fulfilled'));
    expect(order, isNot(contains('cart_id')));
    expect(order, isNot(contains('customer_id')));
    expect(order, isNot(contains('metadata')));

    final items = order['items']! as List<Object?>;
    expect(items, hasLength(2));
    expect(
      items.map((item) => (item! as Map<String, Object?>)['id']),
      ['item_cup', 'item_shirt'],
    );
    expect(items.first, isNot(contains('metadata')));
    expect(items.first, containsPair('shipping_profile_id', 'sp_default'));
    expect(
      order['shipping_address'],
      containsPair('country_code', 'dk'),
    );
    expect(
      order['billing_address'],
      containsPair('company', 'Analytical Engines'),
    );
    final fulfillments = order['fulfillments']! as List<Object?>;
    expect(fulfillments, hasLength(1));
    final fulfillment = fulfillments.single! as Map<String, Object?>;
    expect(fulfillment.keys, {
      'canceled_at',
      'created_at',
      'created_by',
      'data',
      'delivered_at',
      'id',
      'items',
      'labels',
      'location_id',
      'marked_shipped_by',
      'metadata',
      'packed_at',
      'provider_id',
      'requires_shipping',
      'shipped_at',
      'shipping_option_id',
      'updated_at',
    });
    expect(fulfillment, containsPair('provider_id', 'manual'));
    expect(fulfillment, containsPair('created_by', 'admin_1'));
    final fulfilledItems = fulfillment['items']! as List<Object?>;
    expect(fulfilledItems, hasLength(1));
    expect(
      fulfilledItems.single,
      containsPair('line_item_id', 'item_cup'),
    );
    final labels = fulfillment['labels']! as List<Object?>;
    expect(labels, hasLength(1));
    final label = labels.single! as Map<String, Object?>;
    expect(label.keys, {
      'created_at',
      'fulfillment_id',
      'id',
      'label_url',
      'tracking_number',
      'tracking_url',
      'updated_at',
    });
    expect(label, containsPair('tracking_number', 'TRACK-123'));
    expect(label, isNot(contains('deleted_at')));
  });

  test('unknown and soft-deleted orders are not found', () async {
    final token = await harness.adminToken();
    final missing = harness.client.get('/admin/orders/missing')..bearer(token);
    (await missing.send()).assertNotFound();

    await harness.raw("UPDATE orders SET deleted_at = created_at "
        "WHERE id = 'ord_detail'");
    final deleted = harness.client.get('/admin/orders/ord_detail')
      ..bearer(token);
    (await deleted.send()).assertNotFound();
  });
}
