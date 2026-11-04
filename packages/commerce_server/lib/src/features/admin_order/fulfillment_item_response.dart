import 'package:dust_dart/serde.dart';

part 'fulfillment_item_response.g.dart';

/// Merchant-safe fulfillment item decoded from the SQL detail projection.
@Derive([Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminFulfillmentItemResponse with _$AdminFulfillmentItemResponse {
  /// Creates one explicit fulfillment-item response.
  const AdminFulfillmentItemResponse({
    required this.id,
    required this.fulfillmentId,
    required this.title,
    required this.quantity,
    required this.sku,
    required this.barcode,
    required this.lineItemId,
    required this.inventoryItemId,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Decodes one JSON row selected by SQLite.
  factory AdminFulfillmentItemResponse.fromJson(Map<String, Object?> json) =>
      _$AdminFulfillmentItemResponseFromJson(json);

  /// Provider barcode snapshot; empty when the variant has none.
  final String barcode;

  /// Database-generated creation instant.
  final DateTime createdAt;

  /// Parent fulfillment identifier.
  final String fulfillmentId;

  /// Stable fulfillment-item identifier.
  final String id;

  /// Inventory identity, absent until managed inventory exists.
  final String? inventoryItemId;

  /// Frozen order-line identity when linked to an order.
  final String? lineItemId;

  /// Positive quantity assigned to the fulfillment.
  final int quantity;

  /// Provider SKU snapshot; empty when the variant has none.
  final String sku;

  /// Provider-facing title frozen when fulfillment was created.
  final String title;

  /// Database-generated last mutation instant.
  final DateTime updatedAt;
}
