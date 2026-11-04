import 'package:admin_app/src/order/admin_order_detail_state.dart';
import 'package:admin_app/src/order/admin_order_detail_view_model.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

/// Confirmation prompt for Medusa's irreversible whole-order cancellation.
final class AdminCancelOrderDialog extends StatelessWidget {
  /// Creates the source-matched prompt for [order].
  const AdminCancelOrderDialog({required this.order, super.key});

  /// Eligible order targeted by the confirmation.
  final AdminOrderDetail order;

  Future<void> _submit(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final saved =
        await context.readAdminOrderDetailViewModel().cancelOrder(order.id);
    if (!saved || !context.mounted) return;
    Navigator.of(context).pop();
    messenger.showSnackBar(
      const SnackBar(content: Text('Order canceled successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final detail = context.watchAdminOrderDetailViewModel().value;
    final saving = detail.status == AdminOrderDetailStatus.saving;
    return AlertDialog(
      title: const Text('Are you sure?'),
      content: SizedBox(
        width: 440,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'You are about to cancel the order #${order.displayId}. '
              'This action cannot be undone.',
            ),
            if (detail.failure case Some(:final value)) ...[
              const SizedBox(height: 16),
              Text(value),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: saving ? null : Navigator.of(context).pop,
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: saving ? null : () => _submit(context),
          child: Text(saving ? 'Saving…' : 'Continue'),
        ),
      ],
    );
  }
}
