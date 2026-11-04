import 'package:admin_app/src/core/admin_date_filter_control.dart';
import 'package:admin_app/src/promotion/admin_promotion_state.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:flutter/material.dart';

/// Active promotion date constraints with direct clear actions.
final class AdminPromotionActiveFilters extends StatelessWidget {
  /// Creates the active-filter row.
  const AdminPromotionActiveFilters({
    required this.state,
    required this.onCreatedAtChanged,
    required this.onUpdatedAtChanged,
    required this.onClearAll,
    super.key,
  });

  /// Clears every promotion date filter.
  final VoidCallback onClearAll;

  /// Applies or clears the creation-time constraint.
  final ValueChanged<AdminDateFilter> onCreatedAtChanged;

  /// Applies or clears the update-time constraint.
  final ValueChanged<AdminDateFilter> onUpdatedAtChanged;

  /// Current server query state.
  final AdminPromotionState state;

  @override
  Widget build(BuildContext context) {
    if (!state.hasFilters) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      child: Row(children: [
        Expanded(
          child: Wrap(spacing: 8, runSpacing: 8, children: [
            if (!state.createdAt.isEmpty)
              AdminDateFilterChip(
                label: 'Created',
                value: state.createdAt,
                onChanged: onCreatedAtChanged,
              ),
            if (!state.updatedAt.isEmpty)
              AdminDateFilterChip(
                label: 'Updated',
                value: state.updatedAt,
                onChanged: onUpdatedAtChanged,
              ),
          ]),
        ),
        TextButton(onPressed: onClearAll, child: const Text('Clear all')),
      ]),
    );
  }
}
