import 'package:commerce_admin_shared/src/admin_option.dart';
import 'package:dust_dart/serde.dart';

part 'admin_fulfillment_item.g.dart';

/// One provider-facing order-line snapshot inside an Admin fulfillment.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminFulfillmentItem with _$AdminFulfillmentItem {
  /// Creates the explicit merchant fulfillment-item response.
  const AdminFulfillmentItem({
    required this.id,
    required this.fulfillmentId,
    required this.title,
    required this.quantity,
    required this.sku,
    required this.barcode,
    required this.lineItemIdValue,
    required this.inventoryItemIdValue,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Decodes one generated Admin fulfillment-item response.
  factory AdminFulfillmentItem.fromJson(Map<String, Object?> json) =>
      _$AdminFulfillmentItemFromJson(json);

  /// Provider barcode snapshot; empty when the variant has none.
  final String barcode;

  /// Database-generated creation instant.
  final DateTime createdAt;

  /// Parent fulfillment identifier.
  final String fulfillmentId;

  /// Stable fulfillment-item identifier.
  final String id;

  /// Nullable JSON backing for [inventoryItemId].
  @SerDe(rename: 'inventory_item_id')
  final String? inventoryItemIdValue;

  /// Nullable JSON backing for [lineItemId].
  @SerDe(rename: 'line_item_id')
  final String? lineItemIdValue;

  /// Positive quantity assigned to the fulfillment.
  final int quantity;

  /// Provider SKU snapshot; empty when the variant has none.
  final String sku;

  /// Provider-facing title frozen when fulfillment was created.
  final String title;

  /// Database-generated last mutation instant.
  final DateTime updatedAt;

  /// Inventory identity, absent until managed inventory exists.
  Option<String> get inventoryItemId => adminOptionOf(inventoryItemIdValue);

  /// Frozen order-line identity when linked to an order.
  Option<String> get lineItemId => adminOptionOf(lineItemIdValue);
}
