import 'package:admin_app/src/product_type/admin_product_type_view_model.dart';
import 'package:flutter/material.dart';

/// Confirms retirement with the product-type value in view.
Future<bool> confirmAdminProductTypeDelete(
  BuildContext context,
  String value,
) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Are you sure?'),
        content: Text(
          'Delete "$value"? Products keep working but lose this classification.',
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
String adminProductTypeDeleteMessage(
  AdminProductTypeDeleteOutcome outcome,
  String value,
) =>
    switch (outcome) {
      AdminProductTypeDeleteOutcome.deleted => 'Product type "$value" deleted.',
      AdminProductTypeDeleteOutcome.expired =>
        'Your admin session has expired.',
      AdminProductTypeDeleteOutcome.failed =>
        'Unable to delete "$value". Try again.',
    };
