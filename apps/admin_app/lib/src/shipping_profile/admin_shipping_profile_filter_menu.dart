import 'package:flutter/material.dart';

/// Filters exposed by Medusa's shipping-profile table.
enum AdminShippingProfileFilterKind {
  /// Merchant-facing profile name.
  name,

  /// Open fulfillment classification.
  type,

  /// Database-owned creation instant.
  createdAt,

  /// Database-owned update instant.
  updatedAt,
}

/// Medusa-shaped Add filter control with explicit filter choices.
final class AdminShippingProfileFilterMenu extends StatelessWidget {
  /// Creates the profile filter menu.
  const AdminShippingProfileFilterMenu({required this.onSelected, super.key});

  /// Opens the selected filter editor.
  final ValueChanged<AdminShippingProfileFilterKind> onSelected;

  @override
  Widget build(BuildContext context) => PopupMenuButton(
        tooltip: 'Add filter',
        onSelected: onSelected,
        itemBuilder: (context) => const [
          PopupMenuItem(
            value: AdminShippingProfileFilterKind.name,
            child: Text('Name'),
          ),
          PopupMenuItem(
            value: AdminShippingProfileFilterKind.type,
            child: Text('Type'),
          ),
          PopupMenuItem(
            value: AdminShippingProfileFilterKind.createdAt,
            child: Text('Created at'),
          ),
          PopupMenuItem(
            value: AdminShippingProfileFilterKind.updatedAt,
            child: Text('Updated at'),
          ),
        ],
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.add_rounded, size: 16),
            SizedBox(width: 4),
            Text('Add filter'),
          ]),
        ),
      );
}
