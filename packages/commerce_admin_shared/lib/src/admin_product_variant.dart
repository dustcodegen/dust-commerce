import 'package:dust_dart/serde.dart';

import 'admin_variant_price.dart';

part 'admin_product_variant.g.dart';

/// One inventory-bearing variant shown in the admin detail table.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminProductVariant with _$AdminProductVariant {
  /// Creates an explicitly allowlisted merchant variant.
  const AdminProductVariant({
    required this.id,
    required this.title,
    required this.inventoryQuantity,
    required this.manageInventory,
    required this.allowBackorder,
    required this.optionValues,
    required this.prices,
    this.sku,
    this.material,
    this.ean,
    this.upc,
    this.barcode,
    this.weight,
    this.width,
    this.length,
    this.height,
    this.midCode,
    this.hsCode,
    this.originCountry,
  });

  /// Decodes one generated admin variant response.
  factory AdminProductVariant.fromJson(Map<String, Object?> json) =>
      _$AdminProductVariantFromJson(json);

  /// Whether selling beyond tracked stock is allowed.
  final bool allowBackorder;

  /// Optional machine-readable product identifier.
  final String? barcode;

  /// Optional European Article Number used by merchant integrations.
  final String? ean;

  /// Optional height in the merchant's configured unit.
  final double? height;

  /// Optional Harmonized System customs code.
  final String? hsCode;

  /// Stable variant identifier.
  final String id;

  /// Current sellable units.
  final int inventoryQuantity;

  /// Whether this variant uses inventory enforcement.
  final bool manageInventory;

  /// Optional material that differs from the parent product.
  final String? material;

  /// Optional Manufacturer Identification customs code.
  final String? midCode;

  /// Selected value keyed by product-option identifier.
  final Map<String, String> optionValues;

  /// Exact regional prices sorted by currency code.
  final List<AdminProductVariantPrice> prices;

  /// Optional lowercase ISO 3166-1 alpha-2 origin country.
  final String? originCountry;

  /// Optional merchant stock-keeping unit.
  final String? sku;

  /// Merchant-facing variant name.
  final String title;

  /// Optional Universal Product Code used by merchant integrations.
  final String? upc;

  /// Optional weight in the merchant's configured unit.
  final double? weight;

  /// Optional width in the merchant's configured unit.
  final double? width;

  /// Optional length in the merchant's configured unit.
  final double? length;
}
