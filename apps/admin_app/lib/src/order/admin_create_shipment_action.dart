import 'package:admin_app/src/order/admin_create_shipment_dialog.dart';
import 'package:admin_app/src/order/admin_order_detail_state.dart';
import 'package:admin_app/src/order/admin_order_detail_view_model.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

/// Opens Medusa's create-shipment focus flow for one pending fulfillment.
final class AdminCreateShipmentAction extends StatelessWidget {
  /// Creates the action for one physical fulfillment.
  const AdminCreateShipmentAction({
    required this.order,
    required this.fulfillment,
    super.key,
  });

  /// Pending fulfillment to ship.
  final AdminOrderFulfillment fulfillment;

  /// Parent order returned by the mutation.
  final AdminOrderDetail order;

  Future<void> _open(BuildContext context) => showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AdminCreateShipmentDialog(
          order: order,
          fulfillment: fulfillment,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final detail = context.watchAdminOrderDetailViewModel().value;
    return OutlinedButton(
      onPressed: detail.status == AdminOrderDetailStatus.saving ||
              !canShipAdminFulfillment(fulfillment)
          ? null
          : () => _open(context),
      child: const Text('Mark as shipped'),
    );
  }
}

/// Mirrors Medusa's visibility rule for a physical shipment action.
bool canShipAdminFulfillment(AdminOrderFulfillment fulfillment) =>
    fulfillment.requiresShipping &&
    fulfillment.canceledAt is None<DateTime> &&
    fulfillment.shippedAt is None<DateTime> &&
    fulfillment.deliveredAt is None<DateTime>;
