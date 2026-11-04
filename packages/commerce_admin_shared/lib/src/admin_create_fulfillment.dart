import 'package:commerce_admin_shared/src/admin_option.dart';
import 'package:dust_dart/serde.dart';

part 'admin_create_fulfillment.g.dart';

/// One order-line quantity selected for a fulfillment operation.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminCreateFulfillmentItem with _$AdminCreateFulfillmentItem {
  /// Creates one selected order-line quantity.
  const AdminCreateFulfillmentItem({
    required this.id,
    required this.quantity,
  });

  /// Decodes one generated fulfillment item command.
  factory AdminCreateFulfillmentItem.fromJson(Map<String, Object?> json) =>
      _$AdminCreateFulfillmentItemFromJson(json);

  /// Stable order-line identifier owned by the route's order.
  final String id;

  /// Positive quantity to assign in this fulfillment.
  final int quantity;
}

/// Atomic command for Medusa's order fulfillment creation route.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminCreateFulfillment with _$AdminCreateFulfillment {
  /// Creates one merchant-authorized fulfillment command.
  const AdminCreateFulfillment({
    required this.items,
    required this.locationId,
    required this.noNotification,
    required this.shippingOptionIdValue,
  });

  /// Decodes the generated Admin request body.
  factory AdminCreateFulfillment.fromJson(Map<String, Object?> json) =>
      _$AdminCreateFulfillmentFromJson(json);

  /// Non-empty order-line quantities selected by the merchant.
  final List<AdminCreateFulfillmentItem> items;

  /// Active stock location that will source every selected item.
  final String locationId;

  /// Whether provider/customer notification should be suppressed.
  final bool noNotification;

  /// Nullable JSON backing for [shippingOptionId].
  @SerDe(rename: 'shipping_option_id')
  final String? shippingOptionIdValue;

  /// Selected shipping option, absent only for non-shipping fulfillment.
  Option<String> get shippingOptionId => adminOptionOf(shippingOptionIdValue);
}
