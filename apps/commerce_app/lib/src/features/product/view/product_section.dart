import 'package:commerce_app/commerce_app.dart';
import 'package:flutter/material.dart';

/// Source-ordered product section for the active viewport.
class ProductSection extends StatelessWidget {
  /// Creates a product section and exposes its inline actions for visibility.
  const ProductSection({
    required this.state,
    required this.wide,
    required this.inlineActionsKey,
    super.key,
  });

  /// Key measured to show or hide sticky mobile actions.
  final GlobalKey<State<StatefulWidget>> inlineActionsKey;

  /// Current product and selection.
  final ProductDetailState state;

  /// Whether the Medusa small breakpoint has been reached.
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final product = state.product!;
    final info = ProductInfo(product: product);
    final gallery = ProductGallery(
      urls: product
          .imagesForVariant(state.selectedVariant?.id)
          .map((image) => image.url)
          .toList(growable: false),
      fallbackUrl: product.thumbnail,
      wide: wide,
    );
    if (!wide) {
      return SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 32),
              child: info,
            ),
            const SizedBox(height: 32),
            gallery,
            const SizedBox(height: 32),
            KeyedSubtree(
              key: inlineActionsKey,
              child: ProductActions(state: state),
            ),
            const SizedBox(height: 32),
          ],
        ),
      );
    }

    return SliverCrossAxisGroup(
      slivers: [
        SliverConstrainedCrossAxis(
          maxExtent: 300,
          sliver: SliverPersistentHeader(
            pinned: true,
            delegate: _PinnedColumnDelegate(
              extent: 960,
              child: info,
            ),
          ),
        ),
        SliverCrossAxisExpanded(
          flex: 1,
          sliver: SliverToBoxAdapter(child: gallery),
        ),
        SliverConstrainedCrossAxis(
          maxExtent: 300,
          sliver: SliverPersistentHeader(
            pinned: true,
            delegate: _PinnedColumnDelegate(
              extent: 520,
              child: ProductActions(state: state),
            ),
          ),
        ),
      ],
    );
  }
}

class _PinnedColumnDelegate extends SliverPersistentHeaderDelegate {
  const _PinnedColumnDelegate({required this.child, required this.extent});

  final Widget child;
  final double extent;

  @override
  double get maxExtent => extent;

  @override
  double get minExtent => extent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) =>
      Material(
        color: StoreColors.base,
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            // The 64px nav, 24px section inset and this 104px gap reproduce
            // Medusa's viewport-relative top-48 (192px) sticky offset.
            padding: const EdgeInsets.only(top: 104),
            child: child,
          ),
        ),
      );

  @override
  bool shouldRebuild(_PinnedColumnDelegate oldDelegate) =>
      oldDelegate.extent != extent || oldDelegate.child != child;
}
