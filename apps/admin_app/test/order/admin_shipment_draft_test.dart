import 'package:admin_app/src/order/admin_shipment_draft.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter_test/flutter_test.dart';

import 'admin_order_detail_fixture.dart';

void main() {
  test('builds exact fulfillment items and safe Medusa placeholders', () {
    final fulfillment = _fulfillment();

    final command = buildAdminShipmentCommand(
      fulfillment: fulfillment,
      labels: const [
        AdminShipmentLabelDraft(
          trackingNumber: ' TRACK-123 ',
          trackingUrl: '',
          labelUrl: '',
        ),
      ],
    );

    expect(
      command,
      const Some(AdminCreateShipment(
        items: [AdminCreateShipmentItem(id: 'item_cup', quantity: 1)],
        labels: [
          AdminCreateShipmentLabel(
            trackingNumber: 'TRACK-123',
            trackingUrl: '#',
            labelUrl: '#',
          ),
        ],
        noNotification: true,
      )),
    );
  });

  test('drops a fully blank tracking row', () {
    final command = buildAdminShipmentCommand(
      fulfillment: _fulfillment(),
      labels: const [
        AdminShipmentLabelDraft(
          trackingNumber: ' ',
          trackingUrl: '',
          labelUrl: '',
        ),
      ],
    );

    expect((command as Some<AdminCreateShipment>).value.labels, isEmpty);
  });

  test('rejects unsafe URLs and terminal fulfillment state', () {
    expect(
      buildAdminShipmentCommand(
        fulfillment: _fulfillment(),
        labels: const [
          AdminShipmentLabelDraft(
            trackingNumber: 'TRACK-123',
            trackingUrl: 'javascript:alert(1)',
            labelUrl: '',
          ),
        ],
      ),
      const None<AdminCreateShipment>(),
    );

    final shipped = AdminOrderDetail.fromJson(adminShippedOrderDetailJson)
        .fulfillments
        .single;
    expect(
      buildAdminShipmentCommand(fulfillment: shipped, labels: const []),
      const None<AdminCreateShipment>(),
    );
  });
}

AdminOrderFulfillment _fulfillment() =>
    AdminOrderDetail.fromJson(adminFulfilledOrderDetailJson)
        .fulfillments
        .single;
