import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:flutter/material.dart';

/// Allowlisted server-order selector for the profile table.
final class AdminShippingProfileSort extends StatelessWidget {
  /// Creates the profile order menu.
  const AdminShippingProfileSort({
    required this.value,
    required this.onChanged,
    super.key,
  });

  /// Applies one server-owned ordering.
  final ValueChanged<AdminShippingProfileOrder> onChanged;

  /// Current stable ordering.
  final AdminShippingProfileOrder value;

  @override
  Widget build(BuildContext context) => PopupMenuButton(
        initialValue: value,
        tooltip: 'Sort shipping profiles',
        onSelected: onChanged,
        itemBuilder: (context) => AdminShippingProfileOrder.values
            .map((order) => PopupMenuItem(
                  value: order,
                  child: Text(_labels[order]!),
                ))
            .toList(growable: false),
        icon: const Icon(Icons.swap_vert_rounded, size: 18),
      );
}

const Map<AdminShippingProfileOrder, String> _labels = {
  AdminShippingProfileOrder.nameAsc: 'Name: A to Z',
  AdminShippingProfileOrder.nameDesc: 'Name: Z to A',
  AdminShippingProfileOrder.typeAsc: 'Type: A to Z',
  AdminShippingProfileOrder.typeDesc: 'Type: Z to A',
  AdminShippingProfileOrder.createdAtAsc: 'Created: oldest first',
  AdminShippingProfileOrder.createdAtDesc: 'Created: newest first',
  AdminShippingProfileOrder.updatedAtAsc: 'Updated: oldest first',
  AdminShippingProfileOrder.updatedAtDesc: 'Updated: newest first',
};
