import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Gives route-focus forms the Escape behavior advertised by their header.
final class AdminRouteFocusKeyboard extends StatelessWidget {
  /// Creates a keyboard boundary around [child].
  const AdminRouteFocusKeyboard({
    required this.enabled,
    required this.onClose,
    required this.child,
    super.key,
  });

  /// Focus-form content receiving the shortcut.
  final Widget child;

  /// Whether Escape may close the current form.
  final bool enabled;

  /// Closes the route-focus surface.
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) => CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.escape): () {
            if (enabled) onClose();
          },
        },
        child: child,
      );
}

/// Minimal top bar used by Medusa route-focus modals.
final class AdminRouteFocusHeader extends StatelessWidget {
  /// Creates the close affordance.
  const AdminRouteFocusHeader({
    required this.onClose,
    this.trailing,
    super.key,
  });

  /// Closes the focus surface when submission is idle.
  final VoidCallback? onClose;

  /// Optional status content aligned opposite the close affordance.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          border:
              Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
        ),
        child: Row(children: [
          IconButton(
            tooltip: 'Close',
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded, size: 18),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text('esc', style: Theme.of(context).textTheme.labelSmall),
          ),
          const Spacer(),
          if (trailing != null) trailing!,
        ]),
      );
}

/// Sticky actions matching Medusa's route-focus footer.
final class AdminRouteFocusFooter extends StatelessWidget {
  /// Creates cancel and submit actions.
  const AdminRouteFocusFooter({
    required this.busy,
    required this.onCancel,
    required this.onSubmit,
    this.submitLabel = 'Create',
    super.key,
  });

  /// Whether one submission is active.
  final bool busy;

  /// Cancels the current route-focus operation.
  final VoidCallback onCancel;

  /// Submits the current route-focus form.
  final VoidCallback onSubmit;

  /// Visible primary action label.
  final String submitLabel;

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
            onPressed: busy ? null : onSubmit,
            child: busy
                ? const SizedBox.square(
                    dimension: 15,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(submitLabel),
          ),
        ]),
      );
}

/// Optional display-safe failure below a route-focus form.
final class AdminRouteFocusFailure extends StatelessWidget {
  /// Creates the failure region.
  const AdminRouteFocusFailure({required this.failure, super.key});

  /// Current display-safe failure, when present.
  final Option<String> failure;

  @override
  Widget build(BuildContext context) => switch (failure) {
        Some(:final value) => Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              value,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        None() => const SizedBox.shrink(),
      };
}
