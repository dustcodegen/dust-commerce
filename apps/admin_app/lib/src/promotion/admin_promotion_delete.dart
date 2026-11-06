import 'package:admin_app/src/promotion/admin_promotion_detail_view_model.dart';
import 'package:flutter/material.dart';

/// Confirms and retires one promotion through the authenticated Admin API.
Future<bool> deleteAdminPromotion(
  BuildContext context, {
  required String id,
  required String code,
}) async {
  final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete promotion?'),
          content: Text(
            'You are about to delete the promotion $code. '
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

  final deleted = await context.readAdminPromotionDetailViewModel().delete(id);
  if (!context.mounted) return deleted;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        deleted
            ? 'Promotion deleted\n$code was successfully deleted.'
            : 'Failed to delete promotion\nUnable to delete $code. Try again.',
      ),
    ),
  );
  return deleted;
}
