import 'package:admin_app/src/order/admin_return_receive_dialog.dart';
import 'package:admin_app/src/order/admin_return_state.dart';
import 'package:admin_app/src/order/admin_return_view_model.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

/// Medusa-shaped receive-return action below the order Summary.
final class AdminOrderReturnAction extends StatelessWidget {
  /// Creates the action for one complete merchant order.
  const AdminOrderReturnAction({required this.order, super.key});

  /// Order snapshot used to label returned items.
  final AdminOrderDetail order;

  Future<void> _open(BuildContext context, AdminReturn value) =>
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AdminReturnReceiveDialog(
          order: order,
          value: value,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final state = context.watchAdminReturnViewModel().value;
    if (state.returns.isEmpty) {
      return switch (state.status) {
        AdminReturnLoadStatus.loading => const LinearProgressIndicator(),
        AdminReturnLoadStatus.failed => _ReturnLoadFailure(
            message: switch (state.failure) {
              Some(:final value) => value,
              None() => 'Unable to load returns.',
            },
            onRetry: () =>
                context.readAdminReturnViewModel().loadRequested(order.id),
          ),
        _ => const SizedBox.shrink(),
      };
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      alignment: Alignment.centerRight,
      child: state.returns.length == 1
          ? OutlinedButton(
              onPressed: state.status == AdminReturnLoadStatus.saving
                  ? null
                  : () => _open(context, state.returns.single),
              child: const Text('Receive return'),
            )
          : PopupMenuButton<AdminReturn>(
              enabled: state.status != AdminReturnLoadStatus.saving,
              tooltip: 'Receive return',
              onSelected: (value) => _open(context, value),
              itemBuilder: (context) => [
                for (final value in state.returns)
                  PopupMenuItem(
                    value: value,
                    child: Text('Receive return #${value.displayId}'),
                  ),
              ],
              child: const Chip(label: Text('Receive return')),
            ),
    );
  }
}

final class _ReturnLoadFailure extends StatelessWidget {
  const _ReturnLoadFailure({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          Expanded(child: Text(message)),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ]),
      );
}
