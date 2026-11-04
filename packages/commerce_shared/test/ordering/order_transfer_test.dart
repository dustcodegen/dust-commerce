import 'package:commerce_shared/commerce_shared.dart';
import 'package:test/test.dart';

void main() {
  test('transfer view round-trips only the public allowlist', () {
    final transfer = OrderTransferView(
      id: 'transfer_1',
      orderId: 'order_1',
      status: OrderTransferStatus.requested,
      deliveryStatus: OrderTransferDeliveryStatus.sent,
      expiresAt: DateTime.utc(2026, 9, 7, 12),
    );

    expect(
      transfer.toJson(),
      {
        'id': 'transfer_1',
        'order_id': 'order_1',
        'status': 'requested',
        'delivery_status': 'sent',
        'expires_at': '2026-09-07T12:00:00.000Z',
      },
    );
    expect(OrderTransferView.fromJson(transfer.toJson()), transfer);
  });

  test('decision body accepts a bounded capability', () {
    expect(
      const OrderTransferDecisionBody(token: 'capability').validate().isValid,
      isTrue,
    );
  });

  test('decision body rejects empty and oversized capabilities', () {
    expect(
      const OrderTransferDecisionBody(token: '').validate().isValid,
      isFalse,
    );
    expect(
      OrderTransferDecisionBody(token: 'x' * 513).validate().isValid,
      isFalse,
    );
  });
}
