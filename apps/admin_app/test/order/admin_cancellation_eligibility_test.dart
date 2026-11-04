import 'package:admin_app/src/order/admin_cancel_fulfillment_action.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:flutter_test/flutter_test.dart';

import 'admin_order_detail_fixture.dart';

void main() {
  test('only a pending fulfillment can expose Medusa cancellation', () {
    expect(canCancelAdminFulfillment(_fulfillment()), isTrue);
    expect(
      canCancelAdminFulfillment(
        _fulfillment(shippedAt: '2026-09-14T14:00:00.000Z'),
      ),
      isFalse,
    );
    expect(
      canCancelAdminFulfillment(
        _fulfillment(deliveredAt: '2026-09-14T15:00:00.000Z'),
      ),
      isFalse,
    );
    expect(
      canCancelAdminFulfillment(
        _fulfillment(canceledAt: '2026-09-14T16:00:00.000Z'),
      ),
      isFalse,
    );
  });
}

AdminOrderFulfillment _fulfillment({
  String? shippedAt,
  String? deliveredAt,
  String? canceledAt,
}) =>
    AdminOrderFulfillment.fromJson({
      ...adminFulfillmentJson,
      'shipped_at': shippedAt,
      'delivered_at': deliveredAt,
      'canceled_at': canceledAt,
    });
