import 'package:flutter/material.dart';

/// Medusa's customer-address row actions.
final class AdminCustomerAddressActionsMenu extends StatelessWidget {
  /// Creates the delete-only address menu.
  const AdminCustomerAddressActionsMenu({required this.onDelete, super.key});

  /// Opens typed confirmation when deletion is available.
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) => PopupMenuButton<_AddressAction>(
        tooltip: 'Address actions',
        icon: const Icon(Icons.more_horiz_rounded, size: 18),
        onSelected: (_) => onDelete?.call(),
        itemBuilder: (context) => [
          PopupMenuItem(
            value: _AddressAction.delete,
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

enum _AddressAction { delete }
