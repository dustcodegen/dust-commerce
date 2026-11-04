import 'package:admin_app/src/order/admin_order_detail_state.dart';
import 'package:admin_app/src/order/admin_order_detail_view_model.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

/// Confirmation prompt for Medusa's irreversible cancellation transition.
final class AdminCancelFulfillmentDialog extends StatelessWidget {
  /// Creates the prompt for one pending fulfillment.
  const AdminCancelFulfillmentDialog({
    required this.order,
    required this.fulfillment,
    super.key,
  });

  /// Pending fulfillment to cancel.
  final AdminOrderFulfillment fulfillment;

  /// Parent order returned by the mutation.
  final AdminOrderDetail order;

  Future<void> _submit(BuildContext context) async {
    final saved =
        await context.readAdminOrderDetailViewModel().cancelFulfillment(
              order.id,
              fulfillment.id,
              const AdminCancelFulfillment(noNotification: true),
            );
    if (saved && context.mounted) Navigator.of(context).pop();
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
            const Text(
              'You are about to cancel a fulfillment. '
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
