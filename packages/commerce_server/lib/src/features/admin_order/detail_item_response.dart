import 'package:dust_dart/serde.dart';

part 'detail_item_response.g.dart';

/// Merchant-safe line snapshot decoded from the SQL detail projection.
@Derive([Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminOrderItemResponse with _$AdminOrderItemResponse {
  /// Creates one immutable line response.
  const AdminOrderItemResponse({
    required this.id,
    required this.variantId,
    required this.productId,
    required this.shippingProfileId,
    required this.productHandle,
    required this.thumbnail,
    required this.title,
    required this.variantTitle,
    required this.unitAmount,
    required this.currencyCode,
    required this.quantity,
    required this.createdAt,
  });

  /// Decodes one JSON row selected by SQLite.
  factory AdminOrderItemResponse.fromJson(Map<String, Object?> json) =>
      _$AdminOrderItemResponseFromJson(json);

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

  /// Number of purchased units.
  final int quantity;

  /// Product fulfillment profile when the catalog relation still exists.
  final String? shippingProfileId;

  /// Optional product image frozen at checkout.
  final String? thumbnail;

  /// Product title frozen at checkout.
  final String title;

  /// Unit amount in the currency's minor unit.
  final int unitAmount;

  /// Catalog variant identifier frozen at checkout.
  final String variantId;

  /// Optional variant label frozen at checkout.
  final String? variantTitle;
}
