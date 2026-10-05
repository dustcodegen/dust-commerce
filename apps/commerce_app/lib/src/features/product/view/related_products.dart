import 'package:commerce_app/commerce_app.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

/// Real API-backed recommendations translated from Medusa RelatedProducts.
class RelatedProducts extends StatelessWidget {
  /// Creates the recommendation section for [state].
  const RelatedProducts({required this.state, super.key});

  /// Independent recommendation lifecycle and products.
  final ProductDetailState state;

  @override
  Widget build(BuildContext context) {
    if (state.relatedStatus == RelatedProductsStatus.ready &&
        state.relatedProducts.isEmpty) {
      return const SizedBox.shrink();
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 1024;
        return Padding(
          padding: EdgeInsets.symmetric(vertical: wide ? 128 : 64),
          child: Column(
            children: [
              const TranslatedText(
                'shop_related_products',
                defaultText: 'Related products',
                style: TextStyle(color: StoreColors.foregroundSubtle),
              ),
              const SizedBox(height: 24),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 512),
                child: const TranslatedText(
                  'shop_related_products_body',
                  defaultText:
                      'You might also want to check out these products.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, height: 1.5),
                ),
              ),
              const SizedBox(height: 64),
              _RelatedProductsContent(
                state: state,
                width: constraints.maxWidth,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RelatedProductsContent extends StatelessWidget {
  const _RelatedProductsContent({required this.state, required this.width});

  final ProductDetailState state;
  final double width;

  @override
  Widget build(BuildContext context) {
    const spacing = 24.0;
    final preferredColumns = width >= 1280
        ? 4
        : width >= 1024
            ? 3
            : 2;
    final columns = width < spacing ? 1 : preferredColumns;
    final cardWidth = (width - (columns - 1) * spacing) / columns;
    return switch (state.relatedStatus) {
      RelatedProductsStatus.idle ||
      RelatedProductsStatus.loading =>
        const SizedBox(
          height: 220,
          child: Center(child: CircularProgressIndicator()),
        ),
      RelatedProductsStatus.failed => SizedBox(
          height: 160,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  state.relatedMessage ??
                      context.tr(
                        'shop_related_products_failed',
                        defaultText: 'Could not load related products.',
                      ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: context.readProductViewModel().loadRelated,
                  child: const TranslatedText(
                    'shop_retry',
                    defaultText: 'Try again',
                  ),
                ),
              ],
            ),
          ),
        ),
      RelatedProductsStatus.ready => Wrap(
          spacing: spacing,
          runSpacing: 32,
          children: [
            for (final product in state.relatedProducts)
              SizedBox(
                width: cardWidth,
                child: ProductCard(
                  product: product,
                  currencyCode: state.currencyCode,
                ),
              ),
          ],
        ),
    };
  }
}
