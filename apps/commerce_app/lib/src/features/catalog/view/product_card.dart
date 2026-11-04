import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_app/route.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:flutter/material.dart';

/// ProductPreview translated from the Medusa DTC source.
class ProductCard extends StatefulWidget {
  /// Creates a product card.
  const ProductCard({
    required this.product,
    required this.currencyCode,
    this.featured = false,
    super.key,
  });

  /// Currency selected by the catalogue.
  final String currencyCode;

  /// Whether this card uses the wider home-rail image ratio.
  final bool featured;

  /// Product rendered by this card.
  final Product product;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  static const _cardRestShadow = [
    BoxShadow(color: Color(0x14000000), spreadRadius: 1),
    BoxShadow(
      color: Color(0x14000000),
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: -1,
    ),
    BoxShadow(
      color: Color(0x0a000000),
      offset: Offset(0, 2),
      blurRadius: 4,
    ),
  ];

  static const _cardHoverShadow = [
    BoxShadow(color: Color(0x14000000), spreadRadius: 1),
    BoxShadow(
      color: Color(0x14000000),
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: -1,
    ),
    BoxShadow(
      color: Color(0x1a000000),
      offset: Offset(0, 2),
      blurRadius: 8,
    ),
  ];

  var _hovered = false;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final price = product.cheapestIn(widget.currencyCode);
    final original = product.cheapestOriginalIn(widget.currencyCode);
    final readablePrice = price == null ? 'unavailable' : formatMoney(price);
    return Semantics(
      link: true,
      label: '${product.title}, $readablePrice',
      child: InkWell(
        onTap: () => context.navigator.product(handle: product.handle).push(),
        onHover: (hovered) {
          if (_hovered == hovered) return;
          setState(() => _hovered = hovered);
        },
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ProductImage(
              url: product.previewImageUrl,
              aspectRatio: widget.featured ? 11 / 14 : 9 / 16,
              border: false,
              boxShadow: _hovered ? _cardHoverShadow : _cardRestShadow,
              transitionDuration: const Duration(milliseconds: 150),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    product.title,
                    style: const TextStyle(
                      color: StoreColors.foregroundSubtle,
                      fontSize: 14,
                      height: 20 / 14,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (price != null)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (original != null)
                        Text(
                          formatMoney(original),
                          style: const TextStyle(
                            color: StoreColors.foregroundMuted,
                            decoration: TextDecoration.lineThrough,
                            fontSize: 14,
                            height: 20 / 14,
                          ),
                        ),
                      if (original != null) const SizedBox(width: 8),
                      Text(
                        formatMoney(price),
                        style: TextStyle(
                          color: original == null
                              ? StoreColors.foregroundMuted
                              : StoreColors.interactive,
                          fontSize: 14,
                          height: 20 / 14,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
