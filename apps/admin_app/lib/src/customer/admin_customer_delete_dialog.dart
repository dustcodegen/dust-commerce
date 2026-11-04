import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:flutter/material.dart';

/// Opens Medusa's typed confirmation before deleting one customer.
Future<bool> confirmAdminCustomerDelete(
  BuildContext context,
  AdminCustomerDetail customer,
) async {
  final verification = customer.email.match(
    some: (email) => email,
    none: () => customer.id,
  );
  return await showDialog<bool>(
        context: context,
        builder: (context) => AdminCustomerDeleteDialog(
          verification: verification,
        ),
      ) ??
      false;
}

/// Source-faithful typed-to-confirm customer deletion prompt.
final class AdminCustomerDeleteDialog extends StatefulWidget {
  /// Creates a prompt requiring the exact [verification] value.
  const AdminCustomerDeleteDialog({required this.verification, super.key});

  /// Customer email, or the stable id for a contactless legacy profile.
  final String verification;

  @override
  State<AdminCustomerDeleteDialog> createState() =>
      _AdminCustomerDeleteDialogState();
}

final class _AdminCustomerDeleteDialogState
    extends State<AdminCustomerDeleteDialog> {
  final _confirmation = TextEditingController();

  @override
  void dispose() {
    _confirmation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Delete Customer'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(
              'You are about to delete the customer '
              '${widget.verification}. This action cannot be undone.',
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Please type ${widget.verification} to confirm:',
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _confirmation,
              autofocus: true,
              onChanged: (_) => setState(() {}),
            ),
          ]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: _confirmation.text == widget.verification
                ? () => Navigator.of(context).pop(true)
                : null,
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      );
}
