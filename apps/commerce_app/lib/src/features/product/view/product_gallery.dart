import 'package:commerce_app/src/core/product_image.dart';
import 'package:flutter/material.dart';

/// Ordered image stack translated from Medusa DTC `ImageGallery`.
class ProductGallery extends StatelessWidget {
  /// Creates a product gallery.
  const ProductGallery({
    required this.urls,
    required this.fallbackUrl,
    required this.wide,
    super.key,
  });

  /// Primary image used by older catalog records without gallery rows.
  final String? fallbackUrl;

  /// Ordered merchant image URLs.
  final List<String> urls;

  /// Whether the gallery uses the source desktop column gutters.
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final images = urls.isEmpty ? [fallbackUrl] : urls;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: wide ? 64 : 0),
      child: Column(
        children: [
          for (var index = 0; index < images.length; index++) ...[
            ProductImage(
              url: images[index],
              aspectRatio: 29 / 34,
              border: false,
              semanticLabel: 'Product image ${index + 1}',
            ),
            if (index != images.length - 1) const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}
