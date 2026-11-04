import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:test/test.dart';

void main() {
  test('round trips a Medusa order fulfillment command', () {
    const command = AdminCreateFulfillment(
      locationId: 'sloc_main',
      shippingOptionIdValue: 'ship_standard',
      noNotification: false,
      items: [
        AdminCreateFulfillmentItem(id: 'orditem_one', quantity: 2),
      ],
    );

    expect(command.toJson(), {
      'items': [
        {'id': 'orditem_one', 'quantity': 2},
      ],
      'location_id': 'sloc_main',
      'no_notification': false,
      'shipping_option_id': 'ship_standard',
    });
    expect(AdminCreateFulfillment.fromJson(command.toJson()), command);
    expect(command.shippingOptionId, const Some('ship_standard'));
  });

  test('represents a missing shipping option explicitly', () {
    final command = AdminCreateFulfillment.fromJson({
      'items': [
        {'id': 'orditem_one', 'quantity': 1},
      ],
      'location_id': 'sloc_main',
      'no_notification': true,
      'shipping_option_id': null,
    });

    expect(command.shippingOptionId, const None<String>());
    expect(command.noNotification, isTrue);
  });

  test('decodes the explicit fulfillment response and item snapshots', () {
    final fulfillment = AdminOrderFulfillment.fromJson({
      'id': 'ful_01',
      'location_id': 'sloc_main',
      'provider_id': 'manual',
      'shipping_option_id': 'ship_standard',
      'requires_shipping': true,
      'packed_at': null,
      'shipped_at': null,
      'delivered_at': null,
      'canceled_at': null,
      'data': {'service_code': 'ship_standard'},
      'metadata': null,
      'created_by': 'admin_01',
      'marked_shipped_by': null,
      'created_at': '2026-09-14T13:00:00.000Z',
      'updated_at': '2026-09-14T13:00:00.000Z',
      'items': [
        {
          'id': 'fulitem_01',
          'fulfillment_id': 'ful_01',
          'title': 'T-Shirt',
          'quantity': 1,
          'sku': 'TSHIRT-M-BLACK',
          'barcode': '',
          'line_item_id': 'item_01',
          'inventory_item_id': null,
          'created_at': '2026-09-14T13:00:00.000Z',
          'updated_at': '2026-09-14T13:00:00.000Z',
        },
      ],
      'labels': <Object?>[],
    });

    expect(fulfillment.createdAt.isUtc, isTrue);
    expect(fulfillment.shippingOptionId, const Some('ship_standard'));
    expect(fulfillment.packedAt, const None<DateTime>());
    expect(fulfillment.metadata, const None<Map<String, Object?>>());
    expect(fulfillment.createdBy, const Some('admin_01'));
    expect(fulfillment.items.single.lineItemId, const Some('item_01'));
    expect(fulfillment.labels, isEmpty);
    expect(
      fulfillment.items.single.inventoryItemId,
      const None<String>(),
    );
    expect(AdminOrderFulfillment.fromJson(fulfillment.toJson()), fulfillment);
  });

  test('decodes only the Admin fulfillment selection fields', () {
    final locations = AdminStockLocationList.fromJson({
      'stock_locations': [
        {'id': 'sloc_main', 'name': 'Morrow Warehouse'},
      ],
      'count': 1,
      'limit': 20,
      'offset': 0,
    });
    final options = AdminFulfillmentShippingOptionList.fromJson({
      'shipping_options': [
        {
          'id': 'ship_standard',
          'name': 'Standard shipping',
          'shipping_profile_id': 'sp_default',
        },
      ],
      'count': 1,
      'limit': 20,
      'offset': 0,
    });

    expect(locations.stockLocations.single.name, 'Morrow Warehouse');
    expect(options.shippingOptions.single.shippingProfileId, 'sp_default');
    expect(
      AdminStockLocationList.fromJson(locations.toJson()),
      locations,
    );
    expect(
      AdminFulfillmentShippingOptionList.fromJson(options.toJson()),
      options,
    );
  });
}
