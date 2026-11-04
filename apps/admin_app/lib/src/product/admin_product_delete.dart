import 'package:admin_app/src/product/admin_product_view_model.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:flutter/material.dart';

/// Retires one product selected from the compact catalogue row.
Future<bool> deleteAdminProductSummary(
  BuildContext context,
  AdminProduct product,
) =>
    deleteAdminProduct(context, id: product.id, title: product.title);

/// Confirms and retires one product through the authenticated Admin API.
Future<bool> deleteAdminProduct(
  BuildContext context, {
  required String id,
  required String title,
}) async {
  final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Are you sure?'),
          content: Text(
            'You are about to delete the product $title. '
            'This action cannot be undone.',
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
  if (!confirmed || !context.mounted) return false;

  final deleted = await context.readAdminProductViewModel().delete(id);
  if (!context.mounted) return deleted;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        deleted
            ? 'Product deleted\n$title was successfully deleted.'
            : 'Failed to delete product\nUnable to delete $title. Try again.',
      ),
    ),
  );
  return deleted;
}
