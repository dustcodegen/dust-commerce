import 'package:flutter/material.dart';

/// Title bar for the focused promotion creation route.
final class AdminPromotionCreateHeader extends StatelessWidget {
  /// Creates the title bar.
  const AdminPromotionCreateHeader({required this.busy, super.key});

  /// Whether the form can be dismissed.
  final bool busy;

  @override
  Widget build(BuildContext context) => Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        child: Row(children: [
          IconButton(
            tooltip: 'Close',
            onPressed: busy ? null : Navigator.of(context).pop,
            icon: const Icon(Icons.close_rounded, size: 18),
          ),
          const SizedBox(width: 6),
          Text('Create Promotion',
              style: Theme.of(context).textTheme.titleMedium),
        ]),
      );
}

/// Action bar for the focused creation route.
final class AdminPromotionCreateFooter extends StatelessWidget {
  /// Creates the action bar.
  const AdminPromotionCreateFooter({
    required this.busy,
    required this.onCancel,
    required this.onCreate,
    super.key,
  });

  /// Whether the command is running.
  final bool busy;

  /// Closes the form.
  final VoidCallback onCancel;

  /// Submits the form.
  final VoidCallback onCreate;

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
              onPressed: busy ? null : onCancel, child: const Text('Cancel')),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: busy ? null : onCreate,
            child: busy
                ? const SizedBox.square(
                    dimension: 15,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Create'),
          ),
        ]),
      );
}
