import 'package:commerce_app/src/core/store_theme.dart';
import 'package:flutter/material.dart';

/// A source-backed product image with explicit loading and failure states.
class ProductImage extends StatelessWidget {
  /// Creates a product image.
  const ProductImage({
    required this.url,
    this.aspectRatio = 11 / 14,
    this.border = true,
    this.borderRadius = 8,
    this.boxShadow,
    this.placeholderColor,
    this.placeholderSize,
    this.semanticLabel,
    this.transitionDuration = Duration.zero,
    super.key,
  });

  /// Width-to-height ratio of the Medusa image slot.
  final double aspectRatio;

  /// Whether the image slot draws the default storefront border.
  final bool border;

  /// Corner radius for the source image slot.
  final double borderRadius;

  /// Optional source shadow for card-style image slots.
  final List<BoxShadow>? boxShadow;

  /// Optional placeholder icon color for source-specific thumbnail slots.
  final Color? placeholderColor;

  /// Optional placeholder icon size for source-specific thumbnail slots.
  final double? placeholderSize;

  /// Optional accessible label for standalone product imagery.
  final String? semanticLabel;

  /// Optional decoration animation for source hover transitions.
  final Duration transitionDuration;

  /// Remote merchant image URL.
  final String? url;

  @override
  Widget build(BuildContext context) {
    final source = url;
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: AnimatedContainer(
        duration: transitionDuration,
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: StoreColors.subtle,
          border: border ? Border.all(color: StoreColors.border) : null,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: boxShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: source == null
              ? Semantics(
                  label: semanticLabel,
                  child: Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: placeholderColor,
                      size: placeholderSize,
                    ),
                  ),
                )
              : Image.network(
                  source,
                  fit: BoxFit.cover,
                  semanticLabel: semanticLabel,
                  // Medusa's public seed CDN omits CORS headers. An HTML image
                  // keeps merchant-hosted assets usable on web; native targets
                  // continue through Flutter's byte-based network loader.
                  webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
                  errorBuilder: (_, __, ___) => Semantics(
                    label: semanticLabel,
                    child: Center(
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: placeholderColor,
                        size: placeholderSize,
                      ),
                    ),
                  ),
                  loadingBuilder: (context, child, progress) => progress == null
                      ? child
                      : const Center(child: CircularProgressIndicator()),
                ),
        ),
      ),
    );
  }
}
