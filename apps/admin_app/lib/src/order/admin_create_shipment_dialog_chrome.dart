part of 'admin_create_shipment_dialog.dart';

final class _AdminShipmentDialogHeader extends StatelessWidget {
  const _AdminShipmentDialogHeader({
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

final class _AdminShipmentDialogFooter extends StatelessWidget {
  const _AdminShipmentDialogFooter({
    required this.saving,
    required this.onCancel,
    required this.onSubmit,
  });

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
                  onPressed: saving ? null : onSubmit,
                  child: Text(saving ? 'Saving…' : 'Save'),
                ),
              ],
            ),
          ),
        ),
      );
}
