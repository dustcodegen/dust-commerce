import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:flutter/material.dart';

/// Allowlisted server-order selector for the promotions table.
final class AdminPromotionSort extends StatelessWidget {
  /// Creates the promotion order menu.
  const AdminPromotionSort({
    required this.value,
    required this.onChanged,
    super.key,
  });

  /// Applies one server-owned ordering.
  final ValueChanged<AdminPromotionOrder> onChanged;

  /// Current stable ordering.
  final AdminPromotionOrder value;

  @override
  Widget build(BuildContext context) => PopupMenuButton(
        initialValue: value,
        tooltip: 'Sort promotions',
        onSelected: onChanged,
        itemBuilder: (context) => AdminPromotionOrder.values
            .map((order) => PopupMenuItem(
                  value: order,
                  child: Text(_labels[order]!),
                ))
            .toList(growable: false),
        icon: const Icon(Icons.swap_vert_rounded, size: 18),
      );
}

const Map<AdminPromotionOrder, String> _labels = {
  AdminPromotionOrder.createdAtAsc: 'Created: oldest first',
  AdminPromotionOrder.createdAtDesc: 'Created: newest first',
  AdminPromotionOrder.updatedAtAsc: 'Updated: oldest first',
  AdminPromotionOrder.updatedAtDesc: 'Updated: newest first',
};
