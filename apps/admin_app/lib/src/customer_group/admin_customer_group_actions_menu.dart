import 'package:flutter/material.dart';

/// Available actions for one merchant-visible customer group.
final class AdminCustomerGroupActionsMenu extends StatelessWidget {
  /// Creates the currently supported group actions.
  const AdminCustomerGroupActionsMenu({
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  /// Opens the destructive confirmation when deletion is available.
  final VoidCallback? onDelete;

  /// Opens the customer-group name editor.
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) => PopupMenuButton<_CustomerGroupAction>(
        tooltip: 'Customer group actions',
        icon: const Icon(Icons.more_horiz_rounded, size: 18),
        onSelected: (action) => switch (action) {
          _CustomerGroupAction.edit => onEdit(),
          _CustomerGroupAction.delete => onDelete?.call(),
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: _CustomerGroupAction.edit,
            child: Row(children: [
              Icon(Icons.edit_outlined, size: 18),
              SizedBox(width: 10),
              Text('Edit'),
            ]),
          ),
          const PopupMenuDivider(),
          PopupMenuItem(
            value: _CustomerGroupAction.delete,
            enabled: onDelete != null,
            child: Row(children: [
              Icon(
                Icons.delete_outline_rounded,
                size: 18,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(width: 10),
              Text(
                'Delete',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ]),
          ),
        ],
      );
}

enum _CustomerGroupAction { edit, delete }
