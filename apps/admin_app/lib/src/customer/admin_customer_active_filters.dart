import 'package:admin_app/src/customer/admin_customer_state.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Active customer constraints with direct clear actions.
final class AdminCustomerActiveFilters extends StatelessWidget {
  /// Creates the active-filter row.
  const AdminCustomerActiveFilters({
    required this.state,
    required this.onClearAccount,
    required this.onClearCreatedAt,
    required this.onClearUpdatedAt,
    required this.onClearAll,
    super.key,
  });

  /// Clears the registered/guest constraint.
  final VoidCallback onClearAccount;

  /// Clears every customer filter.
  final VoidCallback onClearAll;

  /// Clears the creation-time constraint.
  final VoidCallback onClearCreatedAt;

  /// Clears the update-time constraint.
  final VoidCallback onClearUpdatedAt;

  /// Current server query state.
  final AdminCustomerState state;

  @override
  Widget build(BuildContext context) {
    if (!state.hasFilters) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      child: Row(children: [
        Expanded(
          child: Wrap(spacing: 8, runSpacing: 8, children: [
            if (state.hasAccount case Some(:final value))
              InputChip(
                label: Text('Account: ${value ? 'Registered' : 'Guest'}'),
                onDeleted: onClearAccount,
              ),
            if (!state.createdAt.isEmpty)
              InputChip(
                label: Text('Created: ${_dateLabel(state.createdAt)}'),
                onDeleted: onClearCreatedAt,
              ),
            if (!state.updatedAt.isEmpty)
              InputChip(
                label: Text('Updated: ${_dateLabel(state.updatedAt)}'),
                onDeleted: onClearUpdatedAt,
              ),
          ]),
        ),
        TextButton(onPressed: onClearAll, child: const Text('Clear all')),
      ]),
    );
  }
}

String _dateLabel(AdminDateFilter filter) {
  final format = DateFormat.MMMd();
  final from = filter.greaterThanOrEqual.match(
    some: (date) => format.format(date.toLocal()),
    none: () => '',
  );
  final to = filter.lessThanOrEqual.match(
    some: (date) => format.format(date.toLocal()),
    none: () => '',
  );
  if (from.isNotEmpty && to.isNotEmpty) return '$from – $to';
  if (from.isNotEmpty) return 'since $from';
  return 'before $to';
}
