part of 'admin_product_create_page.dart';

extension on _AdminProductCreatePageState {
  Widget _mediaSection(AdminProductCreateState state) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Media', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(width: 5),
              Text(
                'Optional',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          InkWell(
            onTap: state.isBusy || _media.length == 10 ? null : _pickMedia,
            borderRadius: BorderRadius.circular(8),
            overlayColor: WidgetStateProperty.resolveWith((states) =>
                states.contains(WidgetState.pressed)
                    ? Theme.of(context).colorScheme.surfaceContainer
                    : Colors.transparent),
            child: Container(
              width: double.infinity,
              height: 104,
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (state.status == AdminProductCreateStatus.uploading)
                    const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    const Icon(Icons.file_upload_outlined, size: 18),
                  const SizedBox(height: 7),
                  Text(
                    state.status == AdminProductCreateStatus.uploading
                        ? 'Uploading images'
                        : 'Upload images',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'JPEG, PNG, GIF, or WebP. Up to 5 MB each.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ),
          if (_media.isNotEmpty) ...[
            const SizedBox(height: 8),
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              itemCount: _media.length,
              onReorderItem: _reorderMedia,
              itemBuilder: (context, index) => _MediaRow(
                key: ValueKey(_media[index].file.id),
                index: index,
                draft: _media[index],
                busy: state.isBusy || _discarding,
                onThumbnail: () => _makeThumbnail(index),
                onDelete: () => _removeMedia(index),
              ),
            ),
          ],
        ],
      );
}

final class _MediaRow extends StatelessWidget {
  const _MediaRow({
    required this.index,
    required this.draft,
    required this.busy,
    required this.onThumbnail,
    required this.onDelete,
    super.key,
  });

  final bool busy;
  final _UploadedMediaDraft draft;
  final int index;
  final VoidCallback onDelete;
  final VoidCallback onThumbnail;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Container(
          height: 58,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              ReorderableDragStartListener(
                index: index,
                enabled: !busy,
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(Icons.drag_indicator_rounded, size: 18),
                ),
              ),
              const SizedBox(width: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  width: 34,
                  height: 42,
                  child: Image.network(draft.file.url, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(draft.file.filename,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    Row(children: [
                      if (draft.isThumbnail)
                        const Icon(Icons.photo_size_select_actual_outlined,
                            size: 13),
                      const SizedBox(width: 4),
                      Text(_fileSize(draft.file.size)),
                    ]),
                  ],
                ),
              ),
              PopupMenuButton<_MediaAction>(
                enabled: !busy,
                tooltip: 'Image actions',
                onSelected: (action) => switch (action) {
                  _MediaAction.thumbnail => onThumbnail(),
                  _MediaAction.delete => onDelete(),
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: _MediaAction.thumbnail,
                    child: Text('Make thumbnail'),
                  ),
                  PopupMenuItem(
                    value: _MediaAction.delete,
                    child: Text('Delete'),
                  ),
                ],
              ),
              IconButton(
                tooltip: 'Remove image',
                onPressed: busy ? null : onDelete,
                icon: const Icon(Icons.close_rounded, size: 18),
              ),
            ],
          ),
        ),
      );

  static String _fileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

enum _MediaAction { thumbnail, delete }
