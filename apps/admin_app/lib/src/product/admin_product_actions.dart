import 'package:flutter/material.dart';

/// Medusa-shaped product command menu shared by list and detail routes.
final class AdminProductActions extends StatelessWidget {
  /// Creates Edit and destructive Delete actions.
  const AdminProductActions({
    required this.onEdit,
    required this.onDelete,
    this.iconSize = 18,
    super.key,
  });

  /// Size of the compact overflow icon.
  final double iconSize;

  /// Retires the selected product after confirmation.
  final VoidCallback onDelete;

  /// Opens the selected product for editing.
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) => PopupMenuButton<String>(
        tooltip: 'Product actions',
        padding: EdgeInsets.zero,
        icon: Icon(Icons.more_horiz_rounded, size: iconSize),
        onSelected: (value) => switch (value) {
          'delete' => onDelete(),
          _ => onEdit(),
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit_outlined, size: 17),
                SizedBox(width: 10),
                Text('Edit'),
              ],
            ),
          ),
          const PopupMenuDivider(),
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(
                  Icons.delete_outline_rounded,
                  size: 17,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: 10),
                Text(
                  'Delete',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
}
