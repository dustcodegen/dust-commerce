import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:flutter/material.dart';

/// Opens Medusa's typed confirmation for one customer address.
Future<bool> confirmAdminCustomerAddressDelete(
  BuildContext context,
  AdminCustomerAddress address,
) async {
  final verification = address.addressName.match(
    some: (name) => name,
    none: () => 'address',
  );
  final title = address.addressName.match(
    some: (name) => name,
    none: () => 'n/a',
  );
  return await showDialog<bool>(
        context: context,
        builder: (context) => AdminCustomerAddressDeleteDialog(
          title: title,
          verification: verification,
        ),
      ) ??
      false;
}

/// Source-faithful typed-to-confirm address deletion prompt.
final class AdminCustomerAddressDeleteDialog extends StatefulWidget {
  /// Creates a prompt for the visible address [title].
  const AdminCustomerAddressDeleteDialog({
    required this.title,
    required this.verification,
    super.key,
  });

  /// Address name rendered in the destructive warning.
  final String title;

  /// Exact address name, or Medusa's `address` fallback.
  final String verification;

  @override
  State<AdminCustomerAddressDeleteDialog> createState() =>
      _AdminCustomerAddressDeleteDialogState();
}

final class _AdminCustomerAddressDeleteDialogState
    extends State<AdminCustomerAddressDeleteDialog> {
  final _confirmation = TextEditingController();

  @override
  void dispose() {
    _confirmation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Are you sure?'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(
              'You are about to delete the Address ${widget.title}. '
              'This action cannot be undone.',
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
