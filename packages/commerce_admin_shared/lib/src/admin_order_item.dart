import 'package:commerce_admin_shared/src/admin_option.dart';
import 'package:dust_dart/serde.dart';

part 'admin_order_item.g.dart';

/// One immutable line snapshot shown in the merchant order detail.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminOrderItem with _$AdminOrderItem {
  /// Creates a safe line-item response detached from mutable catalog data.
  const AdminOrderItem({
    required this.id,
    required this.variantId,
    required this.productId,
    required this.shippingProfileIdValue,
    required this.productHandle,
    required this.thumbnailValue,
    required this.title,
    required this.variantTitleValue,
    required this.unitAmount,
    required this.currencyCode,
    required this.quantity,
    required this.createdAt,
  });

  /// Decodes one generated Admin line response.
  factory AdminOrderItem.fromJson(Map<String, Object?> json) =>
      _$AdminOrderItemFromJson(json);

  /// Database-generated snapshot creation instant.
  final DateTime createdAt;

  /// Lowercase ISO 4217 currency for [unitAmount].
  final String currencyCode;

  /// Stable line identifier.
  final String id;

  /// Product route handle frozen at checkout.
  final String productHandle;

  /// Product identifier frozen at checkout.
  final String productId;

  /// Number of units purchased.
  final int quantity;

  /// Nullable JSON backing for [shippingProfileId].
  @SerDe(rename: 'shipping_profile_id')
  final String? shippingProfileIdValue;

  /// Nullable JSON backing for [thumbnail].
  @SerDe(rename: 'thumbnail')
  final String? thumbnailValue;

  /// Product title frozen at checkout.
  final String title;

  /// Unit amount in the currency's minor unit.
  final int unitAmount;

  /// Catalog variant identifier frozen at checkout.
  final String variantId;

  /// Nullable JSON backing for [variantTitle].
  @SerDe(rename: 'variant_title')
  final String? variantTitleValue;

  /// Optional product image frozen at checkout.
  Option<String> get thumbnail => adminOptionOf(thumbnailValue);

  /// Product fulfillment profile used to filter shipping methods.
  Option<String> get shippingProfileId => adminOptionOf(shippingProfileIdValue);

  /// Optional variant label frozen at checkout.
  Option<String> get variantTitle => adminOptionOf(variantTitleValue);
}
