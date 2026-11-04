import 'package:commerce_shared/src/catalog/image.dart';
import 'package:commerce_shared/src/money.dart';
import 'package:dust_dart/serde.dart';

part 'variant.g.dart';

/// A single buyable configuration of a product.
///
/// The variant, not the product, carries price and stock. A medium black
/// shirt and a large black shirt are different things to sell, count, and
/// ship, and a model that prices the product cannot express that.
@Derive([ToString(), Eq(), CopyWith(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
class ProductVariant with _$ProductVariant {
  /// Creates a [ProductVariant] from already-validated values.
  const ProductVariant({
    required this.id,
    required this.title,
    required this.prices,
    required this.optionValues,
    this.images = const [],
    this.originalPrices = const [],
    this.sku,
    this.inventoryQuantity = 0,
    this.manageInventory = true,
    this.allowBackorder = false,
  });

  /// Creates a [ProductVariant], rejecting duplicate currencies and negative
  /// stock.
  factory ProductVariant.of({
    required String id,
    required String title,
    required List<Money> prices,
    List<Money> originalPrices = const [],
    String? sku,
    int inventoryQuantity = 0,
    bool manageInventory = true,
    bool allowBackorder = false,
    Map<String, String> optionValues = const {},
    List<StoreProductImage> images = const [],
  }) {
    _checkPrices(prices);
    _checkPrices(originalPrices, name: 'originalPrices');
    if (inventoryQuantity < 0) {
      throw ArgumentError.value(
        inventoryQuantity,
        'inventoryQuantity',
        'stock cannot be negative',
      );
    }
    return ProductVariant(
      id: id,
      title: title,
      prices: prices,
      originalPrices: originalPrices,
      sku: sku,
      inventoryQuantity: inventoryQuantity,
      manageInventory: manageInventory,
      allowBackorder: allowBackorder,
      optionValues: optionValues,
      images: images,
    );
  }

  /// Creates a [ProductVariant] from JSON.
  factory ProductVariant.fromJson(Map<String, Object?> json) =>
      _$ProductVariantFromJson(json);

  /// Whether this variant may be sold past its stock on hand.
  final bool allowBackorder;

  /// Unique identifier.
  final String id;

  /// Product images explicitly associated with this variant.
  final List<StoreProductImage> images;

  /// Units on hand. Meaningful only when [manageInventory] is true.
  final int inventoryQuantity;

  /// Whether stock is tracked at all. A download does not track stock.
  final bool manageInventory;

  /// The chosen value per option id, such as `{'opt_size': 'Small'}`.
  final Map<String, String> optionValues;

  /// Crossed-out prices before sale pricing, one per currency at most.
  final List<Money> originalPrices;

  /// At most one price per currency.
  final List<Money> prices;

  /// Stock keeping unit, when the seller uses one.
  final String? sku;

  /// Display name, such as `Small / Black`.
  final String title;

  /// Whether at least one unit can be sold right now.
  bool get isInStock => canFulfil(1);

  /// Whether [quantity] units can be sold right now.
  ///
  /// Unmanaged inventory and backorders are both unlimited; the difference is
  /// that one never had stock to track and the other has run out and does not
  /// mind.
  bool canFulfil(int quantity) {
    if (quantity < 1) {
      throw ArgumentError.value(quantity, 'quantity', 'expected at least one');
    }
    if (!manageInventory || allowBackorder) return true;
    return inventoryQuantity >= quantity;
  }

  /// This variant's price in [currencyCode], or null if not sold in it.
  Money? priceIn(String currencyCode) {
    final wanted = currencyCode.toLowerCase();
    for (final price in prices) {
      if (price.currencyCode == wanted) return price;
    }
    return null;
  }

  /// This variant's original crossed-out price in [currencyCode], or null.
  Money? originalPriceIn(String currencyCode) {
    final wanted = currencyCode.toLowerCase();
    for (final price in originalPrices) {
      if (price.currencyCode == wanted) return price;
    }
    return null;
  }

  /// Whether the active price is below its original price in [currencyCode].
  bool isOnSaleIn(String currencyCode) {
    final price = priceIn(currencyCode);
    final original = originalPriceIn(currencyCode);
    return price != null && original != null && original > price;
  }

  /// Rounded sale percentage matching Medusa's storefront display.
  int? salePercentageDiffIn(String currencyCode) {
    final price = priceIn(currencyCode);
    final original = originalPriceIn(currencyCode);
    if (price == null || original == null || original <= price) return null;
    if (original.amount == 0) return null;
    return (((original.amount - price.amount) / original.amount) * 100).round();
  }

  static void _checkPrices(List<Money> prices, {String name = 'prices'}) {
    final currencies = prices.map((price) => price.currencyCode).toList();
    if (currencies.toSet().length != currencies.length) {
      throw ArgumentError.value(
        prices,
        name,
        'a variant has at most one price per currency',
      );
    }
  }
}
