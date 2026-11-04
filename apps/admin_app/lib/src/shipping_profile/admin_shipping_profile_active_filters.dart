import 'package:admin_app/src/shipping_profile/admin_shipping_profile_state.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

/// Active shipping-profile constraints with direct clear actions.
final class AdminShippingProfileActiveFilters extends StatelessWidget {
  /// Creates the active-filter row.
  const AdminShippingProfileActiveFilters({
    required this.state,
    required this.onClearName,
    required this.onClearType,
    required this.onClearCreatedAt,
    required this.onClearUpdatedAt,
    required this.onClearAll,
    super.key,
  });

  /// Clears every filter.
  final VoidCallback onClearAll;

  /// Clears the creation-time filter.
  final VoidCallback onClearCreatedAt;

  /// Clears the name filter.
  final VoidCallback onClearName;

  /// Clears the type filter.
  final VoidCallback onClearType;

  /// Clears the update-time filter.
  final VoidCallback onClearUpdatedAt;

  /// Current query state.
  final AdminShippingProfileState state;

  @override
  Widget build(BuildContext context) {
    if (!state.hasFilters) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      child: Row(children: [
        Expanded(
          child: Wrap(spacing: 8, runSpacing: 8, children: [
            if (state.name.isNotEmpty)
              InputChip(
                label: Text('Name: ${state.name}'),
                onDeleted: onClearName,
              ),
            if (state.type.isNotEmpty)
              InputChip(
                label: Text('Type: ${state.type}'),
                onDeleted: onClearType,
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
  final from = switch (filter.greaterThanOrEqual) {
    Some(value: final date) => _date(date),
    None() => '',
  };
  final to = switch (filter.lessThanOrEqual) {
    Some(value: final date) => _date(date),
    None() => '',
  };
  if (from.isNotEmpty && to.isNotEmpty) return '$from – $to';
  if (from.isNotEmpty) return 'since $from';
  return 'before $to';
}

String _date(DateTime value) {
  final local = value.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  return '${local.year}-$month-$day';
}
