import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

/// Filters exposed by Medusa's customer list source.
enum AdminCustomerFilterKind {
  /// Registered or guest state.
  account,

  /// Database-owned creation instant.
  createdAt,

  /// Database-owned update instant.
  updatedAt,
}

/// Source-shaped Add filter menu.
final class AdminCustomerFilterMenu extends StatelessWidget {
  /// Creates the customer filter menu.
  const AdminCustomerFilterMenu({required this.onSelected, super.key});

  /// Opens the selected filter editor.
  final ValueChanged<AdminCustomerFilterKind> onSelected;

  @override
  Widget build(BuildContext context) => PopupMenuButton(
        tooltip: 'Add filter',
        onSelected: onSelected,
        itemBuilder: (context) => const [
          PopupMenuItem(
            value: AdminCustomerFilterKind.account,
            child: Text('Account'),
          ),
          PopupMenuItem(
            value: AdminCustomerFilterKind.createdAt,
            child: Text('Created'),
          ),
          PopupMenuItem(
            value: AdminCustomerFilterKind.updatedAt,
            child: Text('Updated'),
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

/// Requests Medusa's registered or guest account constraint.
Future<Option<bool>?> showAdminCustomerAccountFilter(
  BuildContext context,
) =>
    showDialog<Option<bool>>(
      context: context,
      builder: (context) => const _AdminCustomerAccountDialog(),
    );

final class _AdminCustomerAccountDialog extends StatelessWidget {
  const _AdminCustomerAccountDialog();

  @override
  Widget build(BuildContext context) => SimpleDialog(
        title: const Text('Filter by account'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, const Some(true)),
            child: const Text('Registered'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, const Some(false)),
            child: const Text('Guest'),
          ),
        ],
      );
}
