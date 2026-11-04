import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_dart/serde.dart';

part 'variant_response.g.dart';

/// Explicit public product-variant response.
///
/// It does not inherit from the domain variant; the wire fields are an
/// allowlist maintained independently from internal catalogue state.
@Derive([Serialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class ProductVariantResponse with _$ProductVariantResponse {
  /// Creates an explicitly allowlisted product variant.
  const ProductVariantResponse({
    required this.id,
    required this.title,
    required this.prices,
    required this.originalPrices,
    required this.optionValues,
    required this.images,
    required this.inventoryQuantity,
    required this.manageInventory,
    required this.allowBackorder,
    this.sku,
  });

  /// Whether sales may exceed tracked stock.
  final bool allowBackorder;

  /// Stable variant identifier.
  final String id;

  /// Storefront images explicitly associated with this variant.
  final List<StoreProductImage> images;

  /// Units currently available.
  final int inventoryQuantity;

  /// Whether inventory is enforced.
  final bool manageInventory;

  /// Selected value per product-option id.
  final Map<String, String> optionValues;

  /// Crossed-out prices before sale pricing, one per currency at most.
  final List<Money> originalPrices;

  /// Currency-scoped public prices.
  final List<Money> prices;

  /// Merchant stock-keeping unit.
  final String? sku;

  /// Customer-facing variant name.
  final String title;
}
