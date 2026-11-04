import 'package:admin_app/src/core/admin_date_filter_control.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:flutter/material.dart';

/// Source-shaped Add filter menu for customer groups.
final class AdminCustomerGroupFilterMenu extends StatelessWidget {
  /// Creates the customer-group filter menu.
  const AdminCustomerGroupFilterMenu({
    required this.createdAt,
    required this.updatedAt,
    required this.onCreatedAtChanged,
    required this.onUpdatedAtChanged,
    super.key,
  });

  /// Current creation-time comparison.
  final AdminDateFilter createdAt;

  /// Applies a creation-time preset or custom range.
  final ValueChanged<AdminDateFilter> onCreatedAtChanged;

  /// Applies an update-time preset or custom range.
  final ValueChanged<AdminDateFilter> onUpdatedAtChanged;

  /// Current update-time comparison.
  final AdminDateFilter updatedAt;

  @override
  Widget build(BuildContext context) {
    if (!createdAt.isEmpty && !updatedAt.isEmpty) {
      return const SizedBox.shrink();
    }
    return MenuAnchor(
      alignmentOffset: const Offset(0, 8),
      menuChildren: [
        if (createdAt.isEmpty)
          AdminDateFilterSubmenu(
            label: 'Created',
            value: createdAt,
            onChanged: onCreatedAtChanged,
          ),
        if (updatedAt.isEmpty)
          AdminDateFilterSubmenu(
            label: 'Updated',
            value: updatedAt,
            onChanged: onUpdatedAtChanged,
          ),
      ],
      builder: (context, controller, child) => OutlinedButton(
        onPressed: controller.isOpen ? controller.close : controller.open,
        child: const Text('Add filter'),
      ),
    );
  }
}
