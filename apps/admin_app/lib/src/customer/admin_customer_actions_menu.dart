import 'package:flutter/material.dart';

/// Available actions for one merchant-visible customer.
final class AdminCustomerActionsMenu extends StatelessWidget {
  /// Creates the currently supported customer actions.
  const AdminCustomerActionsMenu({
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  /// Opens the customer contact editor.
  final VoidCallback onEdit;

  /// Opens typed confirmation for destructive customer deletion.
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) => PopupMenuButton<_CustomerAction>(
        tooltip: 'Customer actions',
        icon: const Icon(Icons.more_horiz_rounded, size: 18),
        onSelected: (action) => switch (action) {
          _CustomerAction.edit => onEdit(),
          _CustomerAction.delete => onDelete?.call(),
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: _CustomerAction.edit,
            child: Row(children: [
              Icon(Icons.edit_outlined, size: 18),
              SizedBox(width: 10),
              Text('Edit'),
            ]),
          ),
          const PopupMenuDivider(),
          PopupMenuItem(
            value: _CustomerAction.delete,
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

enum _CustomerAction { edit, delete }
