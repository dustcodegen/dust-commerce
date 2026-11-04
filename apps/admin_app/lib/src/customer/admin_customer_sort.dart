import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:flutter/material.dart';

/// Allowlisted server-order selector from Medusa's customer table.
final class AdminCustomerSort extends StatelessWidget {
  /// Creates the customer order menu.
  const AdminCustomerSort({
    required this.value,
    required this.onChanged,
    super.key,
  });

  /// Applies one server-owned ordering.
  final ValueChanged<AdminCustomerOrder> onChanged;

  /// Current stable ordering.
  final AdminCustomerOrder value;

  @override
  Widget build(BuildContext context) => PopupMenuButton(
        initialValue: value,
        tooltip: 'Sort customers',
        onSelected: onChanged,
        itemBuilder: (context) => AdminCustomerOrder.values
            .map((order) => PopupMenuItem(
                  value: order,
                  child: Text(_labels[order]!),
                ))
            .toList(growable: false),
        icon: const Icon(Icons.swap_vert_rounded, size: 18),
      );
}

const Map<AdminCustomerOrder, String> _labels = {
  AdminCustomerOrder.emailAsc: 'Email: A to Z',
  AdminCustomerOrder.emailDesc: 'Email: Z to A',
  AdminCustomerOrder.firstNameAsc: 'First name: A to Z',
  AdminCustomerOrder.firstNameDesc: 'First name: Z to A',
  AdminCustomerOrder.lastNameAsc: 'Last name: A to Z',
  AdminCustomerOrder.lastNameDesc: 'Last name: Z to A',
  AdminCustomerOrder.hasAccountAsc: 'Account: guests first',
  AdminCustomerOrder.hasAccountDesc: 'Account: registered first',
  AdminCustomerOrder.createdAtAsc: 'Created: oldest first',
  AdminCustomerOrder.createdAtDesc: 'Created: newest first',
  AdminCustomerOrder.updatedAtAsc: 'Updated: oldest first',
  AdminCustomerOrder.updatedAtDesc: 'Updated: newest first',
};
