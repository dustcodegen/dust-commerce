import 'package:dust_dart/serde.dart';

part 'item_response.g.dart';

/// Explicit merchant response for one returned order-line quantity.
@Derive([Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminReturnItemResponse with _$AdminReturnItemResponse {
  /// Creates one allowlisted return item.
  const AdminReturnItemResponse({
    required this.id,
    required this.orderItemId,
    required this.quantity,
    required this.receivedQuantity,
    required this.damagedQuantity,
    required this.reasonId,
    required this.note,
  });

  /// Decodes one item projected by SQLite JSON aggregation.
  factory AdminReturnItemResponse.fromJson(Map<String, Object?> json) =>
      _$AdminReturnItemResponseFromJson(json);

  /// Units received damaged and excluded from future restocking.
  final int damagedQuantity;

  /// Stable opaque return-item identifier.
  final String id;

  /// Optional customer context for this item.
  final String? note;

  /// Immutable order-line snapshot associated with this request.
  final String orderItemId;

  /// Total units requested for return.
  final int quantity;

  /// Units already received by the merchant.
  final int receivedQuantity;

  /// Selected active or retired reason identifier.
  final String? reasonId;
}
