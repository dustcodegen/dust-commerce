part of 'admin_product_media_editor.dart';

extension on _AdminProductMediaEditorState {
  Widget _mediaTile(int index, bool busy) {
    final item = _media[index];
    final tile = _MediaTileSurface(
      key: ValueKey(item.id),
      item: item,
      busy: busy,
      selected: _selection.contains(item.id),
      onSelected: (selected) => _toggleSelection(item.id, selected),
    );
    if (busy) return tile;
    return DragTarget<int>(
      onWillAcceptWithDetails: (details) => details.data != index,
      onAcceptWithDetails: (details) => _reorder(details.data, index),
      builder: (context, candidates, rejected) => Draggable<int>(
        data: index,
        feedback: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(8),
          child: SizedBox.square(
            dimension: 150,
            child: _MediaImage(item: item),
          ),
        ),
        childWhenDragging: Opacity(opacity: 0.35, child: tile),
        child: MouseRegion(cursor: SystemMouseCursors.grab, child: tile),
      ),
    );
  }

  Widget _failureBanner(String message) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        color: Theme.of(context).colorScheme.errorContainer,
        child: Text(
          message,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
        ),
      );
}

final class _MediaTileSurface extends StatelessWidget {
  const _MediaTileSurface({
    required this.item,
    required this.busy,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final bool busy;
  final _MediaDraft item;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          Positioned.fill(child: _MediaImage(item: item)),
          if (item.isThumbnail)
            const Positioned(
              left: 8,
              top: 8,
              child: AdminProductThumbnailBadge(),
            ),
          Positioned(
            right: 8,
            top: 8,
            child: Checkbox(
              value: selected,
              onChanged: busy
                  ? null
                  : (value) {
                      onSelected(value ?? false);
                    },
            ),
          ),
        ],
      );
}

final class _MediaImage extends StatelessWidget {
  const _MediaImage({required this.item});

  final _MediaDraft item;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          item.url,
          fit: BoxFit.cover,
          webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
          errorBuilder: (_, __, ___) => ColoredBox(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: const Icon(Icons.image_outlined),
          ),
        ),
      );
}
