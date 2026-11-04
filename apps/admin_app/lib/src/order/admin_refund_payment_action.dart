import 'package:admin_app/src/order/admin_order_detail_state.dart';
import 'package:admin_app/src/order/admin_order_detail_view_model.dart';
import 'package:admin_app/src/order/admin_payment_refund_drawer.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

/// Source-shaped payment action that opens the right-side refund drawer.
final class AdminRefundPaymentAction extends StatelessWidget {
  /// Creates the payment-level action menu.
  const AdminRefundPaymentAction({required this.order, super.key});

  /// Current order and payment snapshot.
  final AdminOrderDetail order;

  Future<void> _open(BuildContext context) async {
    await showAdminPaymentRefundDrawer(context, order);
  }

  @override
  Widget build(BuildContext context) {
    final detail = context.watchAdminOrderDetailViewModel().value;
    final enabled = detail.status != AdminOrderDetailStatus.saving &&
        order.paymentStatus == AdminOrderPaymentStatus.captured &&
        order.paymentRefundedAmount <
            switch (order.paymentAmount) {
              Some(:final value) => value,
              None() => 0,
            } &&
        order.paymentCapturedAt is Some<DateTime>;
    return PopupMenuButton<String>(
      tooltip: 'Payment actions',
      onSelected: (_) => _open(context),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'refund',
          enabled: enabled,
          child: const Row(children: [
            Icon(Icons.cancel_outlined, size: 18),
            SizedBox(width: 8),
            Text('Refund'),
          ]),
        ),
      ],
      icon: const Icon(Icons.more_horiz, size: 18),
    );
  }
}
