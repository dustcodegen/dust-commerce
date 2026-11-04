import 'package:dust_dart/serde.dart';

part 'details.g.dart';

/// Physical and merchandising facts shown on a product detail page.
@Derive([ToString(), Eq(), CopyWith(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
class ProductDetails with _$ProductDetails {
  /// Creates optional details for a product.
  const ProductDetails({
    this.material,
    this.originCountry,
    this.productType,
    this.weight,
    this.length,
    this.width,
    this.height,
  });

  /// Creates details from API JSON.
  factory ProductDetails.fromJson(Map<String, Object?> json) =>
      _$ProductDetailsFromJson(json);

  /// Height in the merchant's configured measurement unit.
  final int? height;

  /// Length in the merchant's configured measurement unit.
  final int? length;

  /// Merchant-facing composition.
  final String? material;

  /// ISO 3166-1 alpha-2 country code.
  final String? originCountry;

  /// Simple product classification.
  final String? productType;

  /// Weight in the merchant's configured measurement unit.
  final int? weight;

  /// Width in the merchant's configured measurement unit.
  final int? width;

  /// Whether all three dimensions are available.
  bool get hasDimensions => length != null && width != null && height != null;
}
