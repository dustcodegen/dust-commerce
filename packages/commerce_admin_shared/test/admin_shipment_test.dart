import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:test/test.dart';

void main() {
  test('round trips Medusa fulfillment-cancel input and its default', () {
    const suppressed = AdminCancelFulfillment(noNotification: true);

    expect(suppressed.toJson(), {'no_notification': true});
    expect(AdminCancelFulfillment.fromJson(suppressed.toJson()), suppressed);
    expect(
      AdminCancelFulfillment.fromJson(const {}).noNotification,
      isFalse,
    );
  });

  test('round trips Medusa mark-delivered input and its default', () {
    const suppressed = AdminMarkFulfillmentDelivered(noNotification: true);

    expect(suppressed.toJson(), {'no_notification': true});
    expect(
      AdminMarkFulfillmentDelivered.fromJson(suppressed.toJson()),
      suppressed,
    );
    expect(
      AdminMarkFulfillmentDelivered.fromJson(const {}).noNotification,
      isFalse,
    );
  });

  test('round trips Medusa order shipment input', () {
    const shipment = AdminCreateShipment(
      items: [
        AdminCreateShipmentItem(id: 'item_01', quantity: 2),
      ],
      labels: [
        AdminCreateShipmentLabel(
          trackingNumber: 'TRACK-123',
          trackingUrl: 'https://carrier.example/TRACK-123',
          labelUrl: '#',
        ),
      ],
      noNotification: true,
    );

    expect(shipment.toJson(), {
      'items': [
        {'id': 'item_01', 'quantity': 2},
      ],
      'labels': [
        {
          'tracking_number': 'TRACK-123',
          'tracking_url': 'https://carrier.example/TRACK-123',
          'label_url': '#',
        },
      ],
      'no_notification': true,
    });
    expect(AdminCreateShipment.fromJson(shipment.toJson()), shipment);
  });

  test('decodes explicit fulfillment labels without internal fields', () {
    final label = AdminFulfillmentLabel.fromJson({
      'id': 'ful_label_01',
      'fulfillment_id': 'ful_01',
      'tracking_number': 'TRACK-123',
      'tracking_url': 'https://carrier.example/TRACK-123',
      'label_url': '#',
      'created_at': '2026-09-14T14:00:00.000Z',
      'updated_at': '2026-09-14T14:00:00.000Z',
    });

    expect(label.createdAt.isUtc, isTrue);
    expect(label.trackingNumber, 'TRACK-123');
    expect(label.toJson().containsKey('deleted_at'), isFalse);
    expect(AdminFulfillmentLabel.fromJson(label.toJson()), label);
  });
}
