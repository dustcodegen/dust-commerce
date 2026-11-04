import 'package:commerce_server/src/features/admin_order/fulfillment_item_response.dart';
import 'package:commerce_server/src/features/admin_order/fulfillment_label_response.dart';
import 'package:dust_dart/serde.dart';

part 'fulfillment_response.g.dart';

/// Merchant-safe fulfillment decoded from the SQL order projection.
@Derive([Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminOrderFulfillmentResponse with _$AdminOrderFulfillmentResponse {
  /// Creates one explicit Admin fulfillment response.
  const AdminOrderFulfillmentResponse({
    required this.id,
    required this.locationId,
    required this.providerId,
    required this.shippingOptionId,
    required this.requiresShipping,
    required this.packedAt,
    required this.shippedAt,
    required this.deliveredAt,
    required this.canceledAt,
    required this.data,
    required this.metadata,
    required this.createdBy,
    required this.markedShippedBy,
    required this.createdAt,
    required this.updatedAt,
    required this.items,
    required this.labels,
  });

  /// Decodes one JSON object selected by SQLite.
  factory AdminOrderFulfillmentResponse.fromJson(Map<String, Object?> json) =>
      _$AdminOrderFulfillmentResponseFromJson(json);

  /// Final cancellation time, when canceled.
  final DateTime? canceledAt;

  /// Database-generated creation instant.
  final DateTime createdAt;

  /// Authenticated Admin actor that created the fulfillment.
  final String? createdBy;

  /// Provider configuration explicitly allowlisted for Admin.
  final Map<String, Object?>? data;

  /// Delivery completion time, when recorded.
  final DateTime? deliveredAt;

  /// Stable fulfillment identifier.
  final String id;

  /// Frozen provider-facing item snapshots.
  final List<AdminFulfillmentItemResponse> items;

  /// Active carrier labels in creation order.
  final List<AdminFulfillmentLabelResponse> labels;

  /// Active stock location sourcing the items.
  final String locationId;

  /// Admin actor that marked the fulfillment shipped.
  final String? markedShippedBy;

  /// Merchant extension data explicitly allowlisted for Admin.
  final Map<String, Object?>? metadata;

  /// Packing completion time, when recorded.
  final DateTime? packedAt;

  /// Fulfillment adapter identifier safe for the merchant UI.
  final String providerId;

  /// Whether delivery requires a physical shipment.
  final bool requiresShipping;

  /// Shipment time, when a physical fulfillment left the location.
  final DateTime? shippedAt;

  /// Selected shipping option, absent for non-shipping fulfillment.
  final String? shippingOptionId;

  /// Database-generated last mutation instant.
  final DateTime updatedAt;
}
