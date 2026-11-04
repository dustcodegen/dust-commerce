import 'package:commerce_admin_shared/src/admin_option.dart';
import 'package:dust_dart/serde.dart';

part 'admin_return_item.g.dart';

/// One explicitly allowlisted item quantity in an Admin return response.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminReturnItem with _$AdminReturnItem {
  /// Creates one merchant-visible returned item.
  const AdminReturnItem({
    required this.id,
    required this.orderItemId,
    required this.quantity,
    required this.receivedQuantity,
    required this.damagedQuantity,
    required this.reasonIdValue,
    required this.noteValue,
  });

  /// Decodes one item from the generated Admin response.
  factory AdminReturnItem.fromJson(Map<String, Object?> json) =>
      _$AdminReturnItemFromJson(json);

  /// Units received in damaged condition and excluded from restocking.
  final int damagedQuantity;

  /// Opaque return-item identifier used by receipt mutations.
  final String id;

  /// Optional customer context backing the [note] boundary.
  @SerDe(rename: 'note')
  final String? noteValue;

  /// Immutable order-line snapshot associated with this request.
  final String orderItemId;

  /// Total units the customer asked to return.
  final int quantity;

  /// Optional selected reason backing the [reasonId] boundary.
  @SerDe(rename: 'reason_id')
  final String? reasonIdValue;

  /// Units already received by the merchant.
  final int receivedQuantity;

  /// Customer context when it was supplied for this item.
  Option<String> get note => adminOptionOf(noteValue);

  /// Selected return reason when the customer supplied one.
  Option<String> get reasonId => adminOptionOf(reasonIdValue);
}
