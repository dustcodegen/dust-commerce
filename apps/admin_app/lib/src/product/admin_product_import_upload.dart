import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

/// Medusa-style single-file CSV picker and selected-file preview.
final class AdminProductImportUpload extends StatelessWidget {
  /// Creates the bounded upload surface.
  const AdminProductImportUpload({
    required this.file,
    required this.busy,
    required this.onPick,
    required this.onRemove,
    super.key,
  });

  /// Whether server preprocessing is active.
  final bool busy;

  /// Selected local CSV, absent before upload or after removal.
  final XFile? file;

  /// Opens the platform file picker.
  final VoidCallback? onPick;

  /// Clears the current staged preview.
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Upload', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            'Upload a CSV to create new products or update existing ones.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 140),
            child: switch (file) {
              final XFile selected => _SelectedFile(
                  key: ValueKey(selected.name),
                  file: selected,
                  busy: busy,
                  onRemove: onRemove,
                ),
              null => _EmptyUpload(onPick: onPick),
            },
          ),
        ],
      );
}

final class _EmptyUpload extends StatelessWidget {
  const _EmptyUpload({required this.onPick});

  final VoidCallback? onPick;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onPick,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          key: const ValueKey('empty-import-upload'),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 34, horizontal: 20),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(children: [
            const Icon(Icons.upload_file_outlined, size: 28),
            const SizedBox(height: 10),
            Text('Upload a file',
                style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 4),
            Text('CSV only · maximum 5 MB',
                style: Theme.of(context).textTheme.bodySmall),
          ]),
        ),
      );
}

final class _SelectedFile extends StatelessWidget {
  const _SelectedFile({
    required this.file,
    required this.busy,
    required this.onRemove,
    super.key,
  });

  final bool busy;
  final XFile file;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(children: [
          const Icon(Icons.description_outlined, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(file.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(
                  busy ? 'Processing…' : 'CSV ready',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          if (busy)
            const SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            IconButton(
              tooltip: 'Remove file',
              onPressed: onRemove,
              icon: const Icon(Icons.delete_outline_rounded, size: 19),
            ),
        ]),
      );
}
