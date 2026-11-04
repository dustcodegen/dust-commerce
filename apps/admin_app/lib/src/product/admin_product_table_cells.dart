part of 'admin_product_table.dart';

final class _MutedProductCell extends StatelessWidget {
  const _MutedProductCell({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) => Text(
        value.isEmpty ? '—' : value,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      );
}

final class _ProductRowActions extends StatelessWidget {
  const _ProductRowActions({
    required this.onDelete,
    required this.onOpen,
    required this.product,
  });

  final ValueChanged<AdminProduct>? onDelete;
  final ValueChanged<String> onOpen;
  final AdminProduct product;

  @override
  Widget build(BuildContext context) {
    final delete = onDelete;
    return delete == null
        ? IconButton(
            tooltip: 'Open product',
            onPressed: () => onOpen(product.id),
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.more_horiz_rounded, size: 17),
          )
        : AdminProductActions(
            iconSize: 17,
            onDelete: () => delete(product),
            onEdit: () => onOpen(product.id),
          );
  }
}

final class _ProductStatusCell extends StatelessWidget {
  const _ProductStatusCell({required this.value});

  final AdminProductLifecycle value;

  @override
  Widget build(BuildContext context) {
    final active = value == AdminProductLifecycle.published;
    final color = active ? const Color(0xFF22C55E) : const Color(0xFFA1A1AA);
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 7),
        Flexible(child: Text(_titleCase(value.name))),
      ],
    );
  }
}

final class _ProductThumbnail extends StatelessWidget {
  const _ProductThumbnail({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Container(
          width: 26,
          height: 26,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: url.isEmpty
              ? const Icon(Icons.image_outlined, size: 16)
              : Image.network(
                  url,
                  fit: BoxFit.cover,
                  // Medusa's seed CDN omits CORS headers; HTML rendering keeps
                  // the source image usable on web without proxying secrets.
                  webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.image_outlined, size: 16),
                ),
        ),
      );
}

String _titleCase(String input) => input.isEmpty
    ? 'Unknown'
    : '${input[0].toUpperCase()}${input.substring(1).toLowerCase()}';
