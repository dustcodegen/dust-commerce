import 'package:admin_app/src/shipping_profile/admin_shipping_profile_view_model.dart';
import 'package:flutter/material.dart';

/// Opens Medusa's typed confirmation before retiring one profile.
Future<bool> confirmAdminShippingProfileDelete(
  BuildContext context,
  String name,
) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AdminShippingProfileDeleteDialog(name: name),
    ) ??
    false;

/// Typed-to-confirm destructive profile prompt.
final class AdminShippingProfileDeleteDialog extends StatefulWidget {
  /// Creates a deletion prompt for [name].
  const AdminShippingProfileDeleteDialog({required this.name, super.key});

  /// Exact profile name required for confirmation.
  final String name;

  @override
  State<AdminShippingProfileDeleteDialog> createState() =>
      _AdminShippingProfileDeleteDialogState();
}

final class _AdminShippingProfileDeleteDialogState
    extends State<AdminShippingProfileDeleteDialog> {
  final _confirmation = TextEditingController();

  @override
  void dispose() {
    _confirmation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Delete Shipping Profile'),
        content: SizedBox(
          width: 420,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(
              'You are about to delete the shipping profile '
              '${widget.name}. This action cannot be undone.',
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Type ${widget.name} to confirm',
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
            onPressed: _confirmation.text == widget.name
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

/// Display-safe feedback for one completed deletion attempt.
String adminShippingProfileDeleteMessage(
  AdminShippingProfileDeleteOutcome outcome,
  String name,
) =>
    switch (outcome) {
      AdminShippingProfileDeleteOutcome.deleted =>
        'Shipping profile $name was successfully deleted.',
      AdminShippingProfileDeleteOutcome.expired =>
        'Your admin session has expired.',
      AdminShippingProfileDeleteOutcome.failed =>
        'Unable to delete $name. Try again.',
    };
