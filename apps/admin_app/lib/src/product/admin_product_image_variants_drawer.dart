import 'package:admin_app/src/product/admin_product_detail_view_model.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

part 'admin_product_image_variants_table.dart';
part 'admin_product_image_variants_chrome.dart';

/// Opens Medusa's image-side variant association drawer.
Future<bool?> showAdminProductImageVariantsDrawer(
  BuildContext context,
  AdminProductDetail product,
  AdminProductImage image,
) =>
    showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close associated variants',
      barrierColor: Colors.black.withValues(alpha: 0.24),
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (context, _, __) => Align(
        alignment: Alignment.centerRight,
        child: _ImageVariantsDrawer(product: product, image: image),
      ),
      transitionBuilder: (context, animation, _, child) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        ),
        child: child,
      ),
    );

final class _ImageVariantsDrawer extends StatefulWidget {
  const _ImageVariantsDrawer({required this.product, required this.image});

  final AdminProductImage image;
  final AdminProductDetail product;

  @override
  State<_ImageVariantsDrawer> createState() => _ImageVariantsDrawerState();
}

final class _ImageVariantsDrawerState extends State<_ImageVariantsDrawer> {
  late final Set<String> _initial;
  late final Set<String> _selected;
  var _query = '';

  @override
  void initState() {
    super.initState();
    _initial = widget.image.variantIds.toSet();
    _selected = {..._initial};
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.readAdminProductDetailViewModel().clearFailure();
    });
  }

  List<AdminProductVariant> get _variants {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return widget.product.variants;
    return widget.product.variants
        .where((variant) =>
            variant.title.toLowerCase().contains(query) ||
            (variant.sku?.toLowerCase().contains(query) ?? false))
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watchAdminProductDetailViewModel().value;
    final busy = state.isSaving;
    return Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: 16,
      child: SizedBox(
        width: MediaQuery.sizeOf(context).width.clamp(0, 560).toDouble(),
        height: double.infinity,
        child: SafeArea(
          child: Column(
            children: [
              _header(busy),
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  enabled: !busy,
                  onChanged: (value) => setState(() => _query = value),
                  decoration: const InputDecoration(
                    hintText: 'Search variants',
                    prefixIcon: Icon(Icons.search_rounded, size: 18),
                  ),
                ),
              ),
              Expanded(
                child: _ImageVariantsTable(
                  variants: _variants,
                  selected: _selected,
                  enabled: !busy,
                  onChanged: _toggle,
                  onToggleAll: _toggleAll,
                ),
              ),
              if (state.failure case Some(value: final message))
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    message,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              _footer(busy),
            ],
          ),
        ),
      ),
    );
  }

  void _toggle(String id, {required bool selected}) => setState(() {
        selected ? _selected.add(id) : _selected.remove(id);
      });

  void _toggleAll(bool selected) => setState(() {
        final ids = _variants.map((variant) => variant.id);
        selected ? _selected.addAll(ids) : _selected.removeAll(ids);
      });

  Future<void> _save() async {
    final add = _selected.difference(_initial).toList(growable: false);
    final remove = _initial.difference(_selected).toList(growable: false);
    if (add.isEmpty && remove.isEmpty) {
      Navigator.of(context).pop(false);
      return;
    }
    final saved =
        await context.readAdminProductDetailViewModel().batchImageVariants(
              widget.product.id,
              widget.image.id,
              AdminBatchImageVariants(add: add, remove: remove),
            );
    if (saved && mounted) Navigator.of(context).pop(true);
  }
}
