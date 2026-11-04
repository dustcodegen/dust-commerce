import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:flutter/material.dart';

/// Opens Medusa's confirmation before deleting one customer group.
Future<bool> confirmAdminCustomerGroupDelete(
  BuildContext context,
  AdminCustomerGroupDetail customerGroup,
) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AdminCustomerGroupDeleteDialog(
        name: customerGroup.name,
      ),
    ) ??
    false;

/// Source-faithful customer-group deletion prompt.
final class AdminCustomerGroupDeleteDialog extends StatelessWidget {
  /// Creates a destructive prompt for [name].
  const AdminCustomerGroupDeleteDialog({required this.name, super.key});

  /// Merchant-facing group name included in the warning.
  final String name;

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Delete Customer Group'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Text(
            'You are about to delete the customer group $name. '
            'This action cannot be undone.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      );
}
