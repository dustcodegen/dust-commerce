import 'package:commerce_admin_shared/src/admin_fulfillment_item.dart';
import 'package:commerce_admin_shared/src/admin_fulfillment_label.dart';
import 'package:commerce_admin_shared/src/admin_option.dart';
import 'package:dust_dart/serde.dart';

part 'admin_order_fulfillment.g.dart';

/// One explicit merchant fulfillment detached from provider internals.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminOrderFulfillment with _$AdminOrderFulfillment {
  /// Creates the Admin order fulfillment response.
  const AdminOrderFulfillment({
    required this.id,
    required this.locationId,
    required this.providerId,
    required this.shippingOptionIdValue,
    required this.requiresShipping,
    required this.packedAtValue,
    required this.shippedAtValue,
    required this.deliveredAtValue,
    required this.canceledAtValue,
    required this.dataValue,
    required this.metadataValue,
    required this.createdByValue,
    required this.markedShippedByValue,
    required this.createdAt,
    required this.updatedAt,
    required this.items,
    required this.labels,
  });

  /// Decodes one generated Admin fulfillment response.
  factory AdminOrderFulfillment.fromJson(Map<String, Object?> json) =>
      _$AdminOrderFulfillmentFromJson(json);

  /// Nullable JSON backing for [canceledAt].
  @SerDe(rename: 'canceled_at')
  final DateTime? canceledAtValue;

  /// Database-generated creation instant.
  final DateTime createdAt;

  /// Nullable JSON backing for [createdBy].
  @SerDe(rename: 'created_by')
  final String? createdByValue;

  /// Provider configuration explicitly returned to the Admin client.
  @SerDe(rename: 'data')
  final Map<String, Object?>? dataValue;

  /// Nullable JSON backing for [deliveredAt].
  @SerDe(rename: 'delivered_at')
  final DateTime? deliveredAtValue;

  /// Stable fulfillment identifier.
  final String id;

  /// Frozen provider-facing item snapshots.
  final List<AdminFulfillmentItem> items;

  /// Active carrier labels attached when this fulfillment was shipped.
  @SerDe(defaultValue: <AdminFulfillmentLabel>[])
  final List<AdminFulfillmentLabel> labels;

  /// Active stock location sourcing the items.
  final String locationId;

  /// Nullable JSON backing for [markedShippedBy].
  @SerDe(rename: 'marked_shipped_by')
  final String? markedShippedByValue;

  /// Merchant extension data explicitly returned to Admin only.
  @SerDe(rename: 'metadata')
  final Map<String, Object?>? metadataValue;

  /// Nullable JSON backing for [packedAt].
  @SerDe(rename: 'packed_at')
  final DateTime? packedAtValue;

  /// Fulfillment adapter identifier safe for the merchant UI.
  final String providerId;

  /// Whether delivery requires a physical shipment.
  final bool requiresShipping;

  /// Nullable JSON backing for [shippedAt].
  @SerDe(rename: 'shipped_at')
  final DateTime? shippedAtValue;

  /// Nullable JSON backing for [shippingOptionId].
  @SerDe(rename: 'shipping_option_id')
  final String? shippingOptionIdValue;

  /// Database-generated last mutation instant.
  final DateTime updatedAt;

  /// Final cancellation time, when the fulfillment was canceled.
  Option<DateTime> get canceledAt => adminOptionOf(canceledAtValue);

  /// Authenticated Admin actor that created the fulfillment.
  Option<String> get createdBy => adminOptionOf(createdByValue);

  /// Provider configuration, absent when the adapter needs none.
  Option<Map<String, Object?>> get data => adminOptionOf(dataValue);

  /// Delivery completion time, when recorded.
  Option<DateTime> get deliveredAt => adminOptionOf(deliveredAtValue);

  /// Admin actor that marked the fulfillment shipped.
  Option<String> get markedShippedBy => adminOptionOf(markedShippedByValue);

  /// Merchant extension data, absent when none was supplied.
  Option<Map<String, Object?>> get metadata => adminOptionOf(metadataValue);

  /// Packing completion time, when recorded.
  Option<DateTime> get packedAt => adminOptionOf(packedAtValue);

  /// Shipment time, when a physical fulfillment left the location.
  Option<DateTime> get shippedAt => adminOptionOf(shippedAtValue);

  /// Selected shipping option, absent for non-shipping fulfillment.
  Option<String> get shippingOptionId => adminOptionOf(shippingOptionIdValue);
}
