import 'package:admin_app/src/order/admin_mark_delivered_dialog.dart';
import 'package:admin_app/src/order/admin_order_detail_state.dart';
import 'package:admin_app/src/order/admin_order_detail_view_model.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

/// Opens Medusa's confirmation prompt for an active fulfillment.
final class AdminMarkDeliveredAction extends StatelessWidget {
  /// Creates a delivery action for one active fulfillment.
  const AdminMarkDeliveredAction({
    required this.order,
    required this.fulfillment,
    super.key,
  });

  /// Fulfillment to mark delivered.
  final AdminOrderFulfillment fulfillment;

  /// Parent order returned by the mutation.
  final AdminOrderDetail order;

  Future<void> _open(BuildContext context) => showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AdminMarkDeliveredDialog(
          order: order,
          fulfillment: fulfillment,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final detail = context.watchAdminOrderDetailViewModel().value;
    return OutlinedButton(
      onPressed: detail.status == AdminOrderDetailStatus.saving ||
              !canMarkAdminFulfillmentDelivered(fulfillment)
          ? null
          : () => _open(context),
      child: const Text('Mark as delivered'),
    );
  }
}

/// Mirrors Medusa: shipment is not required before delivery or pickup.
bool canMarkAdminFulfillmentDelivered(AdminOrderFulfillment fulfillment) =>
    fulfillment.canceledAt is None<DateTime> &&
    fulfillment.deliveredAt is None<DateTime>;
