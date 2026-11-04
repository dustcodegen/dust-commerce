import 'package:flutter/material.dart';

/// Selection actions shown beneath the product media grid.
final class AdminProductMediaCommandBar extends StatelessWidget {
  /// Creates actions for the currently selected media.
  const AdminProductMediaCommandBar({
    required this.count,
    required this.onDelete,
    required this.onManageVariants,
    super.key,
  });

  /// Number of selected images.
  final int count;

  /// Deletes the current selection.
  final VoidCallback onDelete;

  /// Manages associations when exactly one image is selected.
  final VoidCallback? onManageVariants;

  @override
  Widget build(BuildContext context) => Material(
        color: const Color(0xFF202020),
        borderRadius: BorderRadius.circular(8),
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$count selected',
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: onDelete,
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                child: const Text('Delete'),
              ),
              if (onManageVariants case final callback?)
                TextButton(
                  onPressed: callback,
                  style: TextButton.styleFrom(foregroundColor: Colors.white),
                  child: const Text('Manage associated variants'),
                ),
            ],
          ),
        ),
      );
}
