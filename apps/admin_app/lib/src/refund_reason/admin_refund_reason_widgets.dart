import 'package:admin_app/src/refund_reason/admin_refund_reason_state.dart';
import 'package:admin_app/src/refund_reason/admin_refund_reason_rows.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

/// Heading for the refund-reason settings route.
final class AdminRefundReasonHeader extends StatelessWidget {
  /// Creates the heading.
  const AdminRefundReasonHeader({required this.onCreate, super.key});

  /// Opens the create form.
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Refund reasons'),
                SizedBox(height: 3),
                Text('Manage choices shown during payment refunds.'),
              ],
            ),
          ),
          FilledButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add_rounded, size: 17),
            label: const Text('Create reason'),
          ),
        ]),
      );
}

/// Search control for the refund-reason table.
final class AdminRefundReasonToolbar extends StatelessWidget {
  /// Creates the toolbar.
  const AdminRefundReasonToolbar({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    super.key,
  });

  /// Search text.
  final TextEditingController controller;

  /// Search focus target.
  final FocusNode focusNode;

  /// Called after the query changes.
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(16),
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          onChanged: onChanged,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search_rounded),
            hintText: 'Search refund reasons',
            border: OutlineInputBorder(),
          ),
        ),
      );
}

/// Displays the server-owned reason rows and failure/empty states.
final class AdminRefundReasonTable extends StatelessWidget {
  /// Creates the table.
  const AdminRefundReasonTable({
    required this.state,
    required this.onEdit,
    required this.onRetire,
    required this.onRetry,
    super.key,
  });

  /// Current table state.
  final AdminRefundReasonState state;

  /// Opens the editor.
  final ValueChanged<AdminRefundReason> onEdit;

  /// Opens retirement confirmation.
  final ValueChanged<AdminRefundReason> onRetire;

  /// Reloads after failure.
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (state.status == AdminRefundReasonLoadStatus.loading &&
        state.reasons.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(48),
        child: CircularProgressIndicator(),
      );
    }
    final failure = state.failure;
    if (failure case Some(value: final message)) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Column(children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
        ]),
      );
    }
    if (state.reasons.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(48),
        child: Text('No refund reasons found.'),
      );
    }
    return Column(
      children: [
        for (final reason in state.reasons)
          AdminRefundReasonRow(
            reason: reason,
            busy: state.busyId == Some(reason.id),
            onEdit: () => onEdit(reason),
            onRetire: () => onRetire(reason),
          ),
      ],
    );
  }
}
