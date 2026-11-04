import 'package:dust_dart/serde.dart';

part 'image.g.dart';

/// One ordered image exposed by the customer storefront.
///
/// This contract is intentionally separate from the admin image response. It
/// contains only what a shopper needs to render and filter a product gallery.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class StoreProductImage with _$StoreProductImage {
  /// Creates a storefront image from its stable identity and display order.
  const StoreProductImage({
    required this.id,
    required this.url,
    required this.rank,
  });

  /// Creates an image from the generated storefront JSON contract.
  factory StoreProductImage.fromJson(Map<String, Object?> json) =>
      _$StoreProductImageFromJson(json);

  /// Stable identity used to match the image to associated variants.
  final String id;

  /// Zero-based merchant-defined order within the product gallery.
  final int rank;

  /// Public image URL rendered by the storefront.
  final String url;
}
