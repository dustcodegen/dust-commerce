part of 'admin_create_fulfillment_dialog.dart';

final class _AdminFulfillmentDialogHeader extends StatelessWidget {
  const _AdminFulfillmentDialogHeader({
    required this.orderNumber,
    required this.onClose,
  });

  final VoidCallback? onClose;
  final int orderNumber;

  @override
  Widget build(BuildContext context) => Material(
        color: Theme.of(context).colorScheme.surface,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
          child: Row(children: [
            IconButton(
              tooltip: 'Close',
              onPressed: onClose,
              icon: const Icon(Icons.close_rounded),
            ),
            const SizedBox(width: 12),
            Text(
              'Create fulfillment',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Spacer(),
            Text(
              'Order #$orderNumber',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ]),
        ),
      );
}

final class _AdminFulfillmentDialogFooter extends StatelessWidget {
  const _AdminFulfillmentDialogFooter({
    required this.saving,
    required this.canSubmit,
    required this.onCancel,
    required this.onSubmit,
  });

  final bool canSubmit;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;
  final bool saving;

  @override
  Widget build(BuildContext context) => Material(
        color: Theme.of(context).colorScheme.surface,
        child: SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: saving ? null : onCancel,
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: saving || !canSubmit ? null : onSubmit,
                  child: Text(saving ? 'Creating…' : 'Create fulfillment'),
                ),
              ],
            ),
          ),
        ),
      );
}

final class _AdminFulfillmentMethodWarning extends StatelessWidget {
  const _AdminFulfillmentMethodWarning();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.tertiaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline_rounded, size: 18),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'This differs from the shipping method selected at checkout.',
              ),
            ),
          ],
        ),
      );
}

final class _AdminFulfillmentNotificationField extends StatelessWidget {
  const _AdminFulfillmentNotificationField();

  @override
  Widget build(BuildContext context) => SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('Send notification'),
        subtitle: const Text(
          'Unavailable until a customer notification provider is configured.',
        ),
        value: false,
        onChanged: null,
      );
}

final class _AdminFulfillmentFormMessage extends StatelessWidget {
  const _AdminFulfillmentFormMessage({
    required this.validation,
    required this.choiceFailure,
    required this.saveFailure,
  });

  final Option<String> choiceFailure;
  final Option<String> saveFailure;
  final String validation;

  @override
  Widget build(BuildContext context) {
    final message = validation.isNotEmpty
        ? validation
        : switch (choiceFailure) {
            Some(:final value) => value,
            None() => switch (saveFailure) {
                Some(:final value) => value,
                None() => '',
              },
          };
    return message.isEmpty
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              message,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          );
  }
}
