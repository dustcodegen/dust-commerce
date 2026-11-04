import 'package:admin_app/src/product/admin_product_thumbnail_badge.dart';
import 'package:admin_app/src/product/detail/admin_product_detail_section.dart';
import 'package:admin_app/src/product/detail/admin_product_media_command_bar.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:flutter/material.dart';

/// Ordered product gallery matching Medusa's selectable media card.
final class AdminProductMediaSection extends StatefulWidget {
  /// Creates the product media section.
  const AdminProductMediaSection({
    required this.product,
    required this.onEdit,
    required this.onDelete,
    required this.onManageVariants,
    super.key,
  });

  /// Deletes the selected image associations from the product gallery.
  final Future<bool> Function(Set<String> imageIds) onDelete;

  /// Opens the focused gallery management surface.
  final VoidCallback onEdit;

  /// Opens variant association management for one image.
  final Future<bool> Function(AdminProductImage image) onManageVariants;

  /// Complete admin product allowlist.
  final AdminProductDetail product;

  @override
  State<AdminProductMediaSection> createState() =>
      _AdminProductMediaSectionState();
}

final class _AdminProductMediaSectionState
    extends State<AdminProductMediaSection> {
  final _selection = <String>{};

  @override
  Widget build(BuildContext context) => AdminProductDetailSection(
        title: 'Media',
        action: adminSectionAction(widget.onEdit),
        padding: const EdgeInsets.all(16),
        child: widget.product.images.isEmpty
            ? const Center(child: Text('No media'))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      for (final image in widget.product.images)
                        _MediaTile(
                          image: image,
                          thumbnail: image.url == widget.product.thumbnail,
                          selected: _selection.contains(image.id),
                          onChanged: (selected) => setState(() {
                            selected
                                ? _selection.add(image.id)
                                : _selection.remove(image.id);
                          }),
                        ),
                    ],
                  ),
                  if (_selection.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Center(
                      child: AdminProductMediaCommandBar(
                        count: _selection.length,
                        onDelete: _delete,
                        onManageVariants:
                            _selection.length == 1 ? _manageVariants : null,
                      ),
                    ),
                  ],
                ],
              ),
      );

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete images?'),
        content: const Text('These images will be removed from the product.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    if (await widget.onDelete({..._selection}) && mounted) {
      setState(_selection.clear);
    }
  }

  Future<void> _manageVariants() async {
    final id = _selection.single;
    final image = widget.product.images.singleWhere((item) => item.id == id);
    _selection.clear();
    if (mounted) setState(() {});
    await widget.onManageVariants(image);
  }
}

final class _MediaTile extends StatelessWidget {
  const _MediaTile({
    required this.image,
    required this.thumbnail,
    required this.selected,
    required this.onChanged,
  });

  final AdminProductImage image;
  final ValueChanged<bool> onChanged;
  final bool selected;
  final bool thumbnail;

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 108,
              height: 108,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Image.network(
                image.url,
                width: 108,
                height: 108,
                fit: BoxFit.cover,
                webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
                errorBuilder: (_, __, ___) => const Icon(Icons.image_outlined),
              ),
            ),
          ),
          if (thumbnail)
            const Positioned(
              left: 7,
              top: 7,
              child: AdminProductThumbnailBadge(),
            ),
          Positioned(
            right: 4,
            top: 4,
            child: Checkbox(
              value: selected,
              onChanged: (value) => onChanged(value ?? false),
            ),
          ),
        ],
      );
}
