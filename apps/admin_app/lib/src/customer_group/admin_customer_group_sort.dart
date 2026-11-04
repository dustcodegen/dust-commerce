import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:flutter/material.dart';

/// Allowlisted server-order selector from Medusa's group table.
final class AdminCustomerGroupSort extends StatelessWidget {
  /// Creates the customer-group order menu.
  const AdminCustomerGroupSort({
    required this.value,
    required this.onChanged,
    super.key,
  });

  /// Applies one server-owned ordering.
  final ValueChanged<AdminCustomerGroupOrder> onChanged;

  /// Current stable ordering.
  final AdminCustomerGroupOrder value;

  @override
  Widget build(BuildContext context) => PopupMenuButton(
        initialValue: value,
        tooltip: 'Sort customer groups',
        onSelected: onChanged,
        itemBuilder: (context) => AdminCustomerGroupOrder.values
            .map((order) => PopupMenuItem(
                  value: order,
                  child: Text(_labels[order]!),
                ))
            .toList(growable: false),
        icon: const Icon(Icons.swap_vert_rounded, size: 18),
      );
}

const Map<AdminCustomerGroupOrder, String> _labels = {
  AdminCustomerGroupOrder.nameAsc: 'Name: A to Z',
  AdminCustomerGroupOrder.nameDesc: 'Name: Z to A',
  AdminCustomerGroupOrder.createdAtAsc: 'Created: oldest first',
  AdminCustomerGroupOrder.createdAtDesc: 'Created: newest first',
  AdminCustomerGroupOrder.updatedAtAsc: 'Updated: oldest first',
  AdminCustomerGroupOrder.updatedAtDesc: 'Updated: newest first',
};
