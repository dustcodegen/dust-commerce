part of 'admin_product_import_chrome.dart';

final class _AdminProductImportBody extends StatelessWidget {
  const _AdminProductImportBody({
    required this.busy,
    required this.failure,
    required this.file,
    required this.onDownloadTemplate,
    required this.onPick,
    required this.onRemove,
    required this.preview,
  });

  final bool busy;
  final String? failure;
  final XFile? file;
  final VoidCallback? onDownloadTemplate;
  final VoidCallback? onPick;
  final VoidCallback? onRemove;
  final AdminProductImportPreview? preview;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(24),
        children: [
          AdminProductImportUpload(
            busy: busy,
            file: file,
            onPick: onPick,
            onRemove: onRemove,
          ),
          if (preview case final value?) ...[
            const SizedBox(height: 24),
            AdminProductImportSummaryCard(preview: value),
          ],
          const SizedBox(height: 28),
          Text(
            'Product import template',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 6),
          Text(
            'Use the template to format products and variants correctly.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: onDownloadTemplate,
              icon: const Icon(Icons.download_outlined, size: 18),
              label: const Text('Download template'),
            ),
          ),
          if (failure case final message?) ...[
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      );
}

final class _AdminProductImportFooter extends StatelessWidget {
  const _AdminProductImportFooter({
    required this.busy,
    required this.onClose,
    required this.onImport,
  });

  final bool busy;
  final VoidCallback? onClose;
  final VoidCallback? onImport;

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
          OutlinedButton(onPressed: onClose, child: const Text('Cancel')),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: onImport,
            child: busy
                ? const SizedBox.square(
                    dimension: 15,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Import'),
          ),
        ]),
      );
}

final class _AdminProductImportHeader extends StatelessWidget {
  const _AdminProductImportHeader({required this.onClose});

  final VoidCallback? onClose;

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
              'Product Import',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          IconButton(
            tooltip: 'Close',
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded, size: 18),
          ),
        ]),
      );
}
