part of 'admin_product_organization_drawer.dart';

final class _AdminProductOrganizationFooter extends StatelessWidget {
  const _AdminProductOrganizationFooter({
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

final class _AdminProductOrganizationHeader extends StatelessWidget {
  const _AdminProductOrganizationHeader({
    required this.busy,
    required this.onClose,
  });

  final bool busy;
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
            child: Text(
              'Edit Organization',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          IconButton(
            tooltip: 'Close',
            onPressed: busy ? null : onClose,
            icon: const Icon(Icons.close_rounded, size: 18),
          ),
        ]),
      );
}
