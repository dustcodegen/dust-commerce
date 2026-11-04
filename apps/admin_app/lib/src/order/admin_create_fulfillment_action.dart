import 'package:admin_app/src/order/admin_create_fulfillment_dialog.dart';
import 'package:admin_app/src/order/admin_fulfillment_context_view_model.dart';
import 'package:admin_app/src/order/admin_fulfillment_draft.dart';
import 'package:admin_app/src/order/admin_order_detail_state.dart';
import 'package:admin_app/src/order/admin_order_detail_view_model.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:flutter/material.dart';

/// Opens Medusa's create-fulfillment flow from the order section header.
final class AdminCreateFulfillmentAction extends StatelessWidget {
  /// Creates the action for one complete order snapshot.
  const AdminCreateFulfillmentAction({required this.order, super.key});

  /// Order whose remaining items may be fulfilled.
  final AdminOrderDetail order;

  Future<void> _open(BuildContext context) async {
    await context.readAdminFulfillmentContextViewModel().load(order.regionId);
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AdminCreateFulfillmentDialog(order: order),
    );
  }

  @override
  Widget build(BuildContext context) {
    final detail = context.watchAdminOrderDetailViewModel().value;
    final hasRemainingItems = adminFulfillableQuantities(order).isNotEmpty;
    return OutlinedButton(
      onPressed:
          detail.status == AdminOrderDetailStatus.saving || !hasRemainingItems
              ? null
              : () => _open(context),
      child: const Text('Create fulfillment'),
    );
  }
}
