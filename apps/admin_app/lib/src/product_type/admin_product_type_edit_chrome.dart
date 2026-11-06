import 'package:flutter/material.dart';

/// Header for the product-type editor drawer.
final class AdminProductTypeEditHeader extends StatelessWidget {
  /// Creates the editor header.
  const AdminProductTypeEditHeader({
    required this.busy,
    required this.onClose,
    super.key,
  });

  /// Whether the current mutation prevents closing.
  final bool busy;

  /// Closes the drawer.
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) => Container(
        height: 62,
        padding: const EdgeInsets.only(left: 24, right: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        child: Row(children: [
          Expanded(
            child: Text('Edit Product Type',
                style: Theme.of(context).textTheme.titleMedium),
          ),
          IconButton(
            tooltip: 'Close',
            onPressed: busy ? null : onClose,
            icon: const Icon(Icons.close_rounded, size: 18),
          ),
        ]),
      );
}

/// Footer actions for the product-type editor drawer.
final class AdminProductTypeEditFooter extends StatelessWidget {
  /// Creates the editor footer.
  const AdminProductTypeEditFooter({
    required this.busy,
    required this.onCancel,
    required this.onSave,
    super.key,
  });

  /// Whether the save request is active.
  final bool busy;

  /// Cancels the edit.
  final VoidCallback onCancel;

  /// Saves the edit.
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) => Container(
        height: 62,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          OutlinedButton(
            onPressed: busy ? null : onCancel,
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: busy ? null : onSave,
            child: busy
                ? const SizedBox.square(
                    dimension: 15,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ]),
      );
}
