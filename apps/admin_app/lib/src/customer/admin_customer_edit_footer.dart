part of 'admin_customer_edit_frame.dart';

/// Sticky customer-edit actions.
final class _AdminCustomerEditFooter extends StatelessWidget {
  /// Creates cancel and save actions.
  const _AdminCustomerEditFooter({
    required this.busy,
    required this.onCancel,
    required this.onSave,
  });

  final bool busy;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) => Container(
        height: 62,
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

/// Optional display-safe customer-edit failure.
final class _AdminCustomerEditFailure extends StatelessWidget {
  /// Creates the failure region.
  const _AdminCustomerEditFailure({required this.failure});

  final Option<String> failure;

  @override
  Widget build(BuildContext context) => switch (failure) {
        Some(:final value) => Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              value,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        None() => const SizedBox.shrink(),
      };
}
