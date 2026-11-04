import 'package:dust_dart/db.dart';

part 'sellable_variant.g.dart';

/// Direct result of the sellable-variant join used by cart mutations.
///
/// This is a query response, not an ORM entity. `FromRow` constructs it from
/// the join once; cart services consume it directly without translating it
/// through the public product-variant API model first.
@Derive([ToString(), Eq(), FromRow()])
final class SellableVariant with _$SellableVariant {
  /// Creates a [SellableVariant].
  const SellableVariant({
    required this.id,
    required this.productId,
    required this.productHandle,
    required this.productTitle,
    required this.title,
    required this.inventoryQuantity,
    required this.manageInventory,
    required this.allowBackorder,
    required this.currencyCode,
    required this.amount,
    this.sku,
    this.thumbnail,
  });

  /// Whether sales may exceed tracked stock.
  @Sqlx(rename: 'allow_backorder')
  final int allowBackorder;

  /// Price in integer minor units.
  final int amount;

  /// Currency for [amount].
  @Sqlx(rename: 'currency_code')
  final String currencyCode;

  /// Variant identifier.
  final String id;

  /// Units currently available.
  @Sqlx(rename: 'inventory_quantity')
  final int inventoryQuantity;

  /// Whether stock is tracked.
  @Sqlx(rename: 'manage_inventory')
  final int manageInventory;

  /// Stable customer-facing product route.
  @Sqlx(rename: 'product_handle')
  final String productHandle;

  /// Product identifier.
  @Sqlx(rename: 'product_id')
  final String productId;

  /// Customer-facing product name.
  @Sqlx(rename: 'product_title')
  final String productTitle;

  /// Stock keeping unit.
  final String? sku;

  /// Primary product image.
  final String? thumbnail;

  /// Customer-facing variant name.
  final String title;

  /// Whether current inventory can satisfy [quantity].
  bool canFulfil(int quantity) {
    if (quantity < 1) {
      throw ArgumentError.value(quantity, 'quantity', 'expected at least one');
    }
    if (manageInventory == 0 || allowBackorder != 0) return true;
    return inventoryQuantity >= quantity;
  }
}
