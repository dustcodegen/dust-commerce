import 'package:flutter/material.dart';

/// Opens Medusa's count-aware prompt before removing group members.
Future<bool> confirmAdminCustomerGroupMemberRemoval(
  BuildContext context,
  int count,
) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AdminCustomerGroupRemoveDialog(count: count),
    ) ??
    false;

/// Source-faithful confirmation for one or many membership removals.
final class AdminCustomerGroupRemoveDialog extends StatelessWidget {
  /// Creates a prompt for [count] selected customers.
  const AdminCustomerGroupRemoveDialog({required this.count, super.key});

  /// Number of memberships removed by the command.
  final int count;

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(count == 1 ? 'Remove customer' : 'Remove customers'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Text(
            'You are about to remove $count '
            '${count == 1 ? 'customer' : 'customers'} from the customer group. '
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
            child: const Text('Continue'),
          ),
        ],
      );
}
