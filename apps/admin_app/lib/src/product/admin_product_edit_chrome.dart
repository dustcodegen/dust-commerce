part of 'admin_product_edit_drawer.dart';

final class _AdminProductEditFooter extends StatelessWidget {
  const _AdminProductEditFooter({
    required this.onCancel,
    required this.onSave,
    required this.saving,
  });

  final VoidCallback onCancel;
  final VoidCallback onSave;
  final bool saving;

  @override
  Widget build(BuildContext context) => Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton(
              onPressed: saving ? null : onCancel,
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: saving ? null : onSave,
              child: saving
                  ? const SizedBox.square(
                      dimension: 15,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ],
        ),
      );
}

final class _AdminProductEditHeader extends StatelessWidget {
  const _AdminProductEditHeader({
    required this.onClose,
    required this.saving,
  });

  final VoidCallback onClose;
  final bool saving;

  @override
  Widget build(BuildContext context) => Container(
        height: 56,
        padding: const EdgeInsets.only(left: 24, right: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Edit product',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            IconButton(
              tooltip: 'Close',
              onPressed: saving ? null : onClose,
              icon: const Icon(Icons.close_rounded, size: 18),
            ),
          ],
        ),
      );
}
