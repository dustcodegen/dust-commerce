import 'package:flutter/material.dart';

/// Full-screen focus frame matching Medusa's route modal structure.
final class AdminShippingProfileCreateFrame extends StatelessWidget {
  /// Creates modal chrome around [body].
  const AdminShippingProfileCreateFrame({
    required this.body,
    required this.busy,
    required this.onCancel,
    required this.onSave,
    super.key,
  });

  /// Form content between fixed chrome.
  final Widget body;

  /// Whether one create request is active.
  final bool busy;

  /// Closes without saving.
  final VoidCallback onCancel;

  /// Submits the form.
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: !busy,
        child: Material(
          color: Theme.of(context).colorScheme.surface,
          child: SafeArea(
            child: Column(children: [
              AdminShippingProfileCreateHeader(
                busy: busy,
                onClose: onCancel,
              ),
              Expanded(child: body),
              AdminShippingProfileCreateFooter(
                busy: busy,
                onCancel: onCancel,
                onSave: onSave,
              ),
            ]),
          ),
        ),
      );
}

/// Fixed route-modal header.
final class AdminShippingProfileCreateHeader extends StatelessWidget {
  /// Creates the close affordance.
  const AdminShippingProfileCreateHeader({
    required this.busy,
    required this.onClose,
    super.key,
  });

  /// Whether closing is disabled.
  final bool busy;

  /// Closes the focus surface.
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) => Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            tooltip: 'Close',
            onPressed: busy ? null : onClose,
            icon: const Icon(Icons.close_rounded, size: 18),
          ),
        ),
      );
}

/// Fixed route-modal footer with source-faithful actions.
final class AdminShippingProfileCreateFooter extends StatelessWidget {
  /// Creates Cancel and Save controls.
  const AdminShippingProfileCreateFooter({
    required this.busy,
    required this.onCancel,
    required this.onSave,
    super.key,
  });

  /// Whether submission is active.
  final bool busy;

  /// Closes without saving.
  final VoidCallback onCancel;

  /// Submits the form.
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) => Container(
        height: 64,
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
