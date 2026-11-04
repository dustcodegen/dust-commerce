import 'package:admin_app/src/product_option/admin_product_option_view_model.dart';
import 'package:flutter/material.dart';

/// Confirms the destructive action with the option title in view.
Future<bool> confirmAdminProductOptionDelete(
  BuildContext context,
  String title,
) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Are you sure?'),
        content: Text(
          'Delete "$title"? This cannot be undone from the Admin app.',
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
      ),
    ) ??
    false;

/// Display-safe feedback for a completed deletion attempt.
String adminProductOptionDeleteMessage(
  AdminProductOptionDeleteOutcome outcome,
  String title,
) =>
    switch (outcome) {
      AdminProductOptionDeleteOutcome.deleted =>
        'Product option "$title" deleted.',
      AdminProductOptionDeleteOutcome.inUse =>
        'Remove "$title" from every product before deleting it.',
      AdminProductOptionDeleteOutcome.expired =>
        'Your admin session has expired.',
      AdminProductOptionDeleteOutcome.failed =>
        'Unable to delete "$title". Try again.',
    };
