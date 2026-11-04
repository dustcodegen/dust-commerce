import 'package:admin_app/src/order/admin_cancel_order_dialog.dart';
import 'package:admin_app/src/order/admin_order_detail_state.dart';
import 'package:admin_app/src/order/admin_order_detail_view_model.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:flutter/material.dart';

/// Medusa-shaped General section menu for whole-order actions.
final class AdminCancelOrderAction extends StatelessWidget {
  /// Creates the action menu for [order].
  const AdminCancelOrderAction({required this.order, super.key});

  /// Current order snapshot returned by the Admin API.
  final AdminOrderDetail order;

  Future<void> _open(BuildContext context) => showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AdminCancelOrderDialog(order: order),
      );

  @override
  Widget build(BuildContext context) {
    final detail = context.watchAdminOrderDetailViewModel().value;
    final enabled = detail.status != AdminOrderDetailStatus.saving &&
        order.status == AdminOrderStatus.pending;
    return PopupMenuButton<String>(
      tooltip: 'Order actions',
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
