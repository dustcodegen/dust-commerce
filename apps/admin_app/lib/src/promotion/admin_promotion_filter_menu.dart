import 'package:admin_app/src/core/admin_date_filter_control.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:flutter/material.dart';

/// Medusa-shaped Add filter control for promotion date fields.
final class AdminPromotionFilterMenu extends StatelessWidget {
  /// Creates the promotion filter menu.
  const AdminPromotionFilterMenu({
    required this.createdAt,
    required this.updatedAt,
    required this.onCreatedAtChanged,
    required this.onUpdatedAtChanged,
    super.key,
  });

  /// Current creation-time bounds.
  final AdminDateFilter createdAt;

  /// Applies the creation-time filter.
  final ValueChanged<AdminDateFilter> onCreatedAtChanged;

  /// Applies the update-time filter.
  final ValueChanged<AdminDateFilter> onUpdatedAtChanged;

  /// Current update-time bounds.
  final AdminDateFilter updatedAt;

  @override
  Widget build(BuildContext context) => MenuAnchor(
        menuChildren: [
          AdminDateFilterSubmenu(
            label: 'Created at',
            value: createdAt,
            onChanged: onCreatedAtChanged,
          ),
          AdminDateFilterSubmenu(
            label: 'Updated at',
            value: updatedAt,
            onChanged: onUpdatedAtChanged,
          ),
        ],
        builder: (context, controller, child) => TextButton.icon(
          onPressed: controller.isOpen ? controller.close : controller.open,
          icon: const Icon(Icons.add_rounded, size: 16),
          label: const Text('Add filter'),
        ),
      );
}
