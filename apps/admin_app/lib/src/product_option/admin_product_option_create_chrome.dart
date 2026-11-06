import 'package:flutter/material.dart';

/// Header chrome for the focused product-option form.
final class AdminProductOptionCreateHeader extends StatelessWidget {
  /// Creates the form header.
  const AdminProductOptionCreateHeader({
    required this.busy,
    required this.onClose,
    super.key,
  });

  /// Whether the create command is in flight.
  final bool busy;

  /// Closes the focus surface.
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) => Container(
        height: 56,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        child: Row(children: [
          const SizedBox(width: 18),
          IconButton(
            tooltip: 'Close',
            onPressed: busy ? null : onClose,
            icon: const Icon(Icons.close_rounded, size: 18),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text('esc', style: Theme.of(context).textTheme.labelSmall),
          ),
        ]),
      );
}

/// Footer actions for the focused product-option form.
final class AdminProductOptionCreateFooter extends StatelessWidget {
  /// Creates the form footer.
  const AdminProductOptionCreateFooter({
    required this.busy,
    required this.onCancel,
    required this.onSave,
    super.key,
  });

  /// Whether the create command is in flight.
  final bool busy;

  /// Cancels the form.
  final VoidCallback onCancel;

  /// Saves the form.
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) => Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          border:
              Border(top: BorderSide(color: Theme.of(context).dividerColor)),
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
