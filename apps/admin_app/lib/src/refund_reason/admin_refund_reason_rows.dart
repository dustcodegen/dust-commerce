import 'package:admin_app/src/refund_reason/admin_refund_reason_state.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:flutter/material.dart';

/// One merchant refund-reason row.
final class AdminRefundReasonRow extends StatelessWidget {
  /// Creates a reason row.
  const AdminRefundReasonRow({
    required this.reason,
    required this.busy,
    required this.onEdit,
    required this.onRetire,
    super.key,
  });

  /// Row data.
  final AdminRefundReason reason;

  /// Whether retirement is in flight.
  final bool busy;

  /// Opens edit.
  final VoidCallback onEdit;

  /// Opens retire confirmation.
  final VoidCallback onRetire;

  @override
  Widget build(BuildContext context) => ListTile(
        title: Text(reason.label),
        subtitle: Text(
          '${reason.code} · ${reason.description.match(
            some: (value) => value,
            none: () => 'No description',
          )}',
        ),
        trailing: Wrap(
          spacing: 4,
          children: [
            IconButton(
              tooltip: 'Edit',
              onPressed: busy ? null : onEdit,
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              tooltip: 'Retire',
              onPressed: busy ? null : onRetire,
              icon: busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.archive_outlined),
            ),
          ],
        ),
      );
}

/// Pagination controls for the reason list.
final class AdminRefundReasonPagination extends StatelessWidget {
  /// Creates pagination controls.
  const AdminRefundReasonPagination({
    required this.state,
    required this.onPrevious,
    required this.onNext,
    super.key,
  });

  /// Current page.
  final AdminRefundReasonState state;

  /// Loads the previous page.
  final VoidCallback onPrevious;

  /// Loads the next page.
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final first = state.reasons.isEmpty ? 0 : state.offset + 1;
    final last = state.offset + state.reasons.length;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(children: [
        Text('$first-$last of ${state.count}'),
        const Spacer(),
        IconButton(
          tooltip: 'Previous page',
          onPressed: state.hasPrevious ? onPrevious : null,
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        IconButton(
          tooltip: 'Next page',
          onPressed: state.hasNext ? onNext : null,
          icon: const Icon(Icons.chevron_right_rounded),
        ),
      ]),
    );
  }
}
