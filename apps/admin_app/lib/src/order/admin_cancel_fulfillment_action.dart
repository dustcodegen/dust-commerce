import 'package:admin_app/src/order/admin_cancel_fulfillment_dialog.dart';
import 'package:admin_app/src/order/admin_order_detail_state.dart';
import 'package:admin_app/src/order/admin_order_detail_view_model.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

/// Medusa-shaped fulfillment menu containing the cancellation action.
final class AdminCancelFulfillmentAction extends StatelessWidget {
  /// Creates the action menu for one fulfillment.
  const AdminCancelFulfillmentAction({
    required this.order,
    required this.fulfillment,
    super.key,
  });

  /// Fulfillment whose pending lifecycle may be canceled.
  final AdminOrderFulfillment fulfillment;

  /// Parent order returned by the cancellation mutation.
  final AdminOrderDetail order;

  Future<void> _open(BuildContext context) => showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AdminCancelFulfillmentDialog(
          order: order,
          fulfillment: fulfillment,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final detail = context.watchAdminOrderDetailViewModel().value;
    final enabled = detail.status != AdminOrderDetailStatus.saving &&
        canCancelAdminFulfillment(fulfillment);
    return PopupMenuButton<String>(
      tooltip: 'Fulfillment actions',
      onSelected: (_) => _open(context),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'cancel',
          enabled: enabled,
          child: Row(children: [
            Icon(
              Icons.cancel_outlined,
              size: 18,
              color: enabled ? Theme.of(context).colorScheme.error : null,
            ),
            const SizedBox(width: 8),
            const Text('Cancel'),
          ]),
        ),
      ],
      icon: const Icon(Icons.more_horiz, size: 18),
    );
  }
}

/// Mirrors Medusa: only an unshipped, undelivered active record can cancel.
bool canCancelAdminFulfillment(AdminOrderFulfillment fulfillment) =>
    fulfillment.canceledAt is None<DateTime> &&
    fulfillment.shippedAt is None<DateTime> &&
    fulfillment.deliveredAt is None<DateTime>;
