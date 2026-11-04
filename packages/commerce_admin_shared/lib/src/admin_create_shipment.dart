import 'package:dust_dart/serde.dart';

part 'admin_create_shipment.g.dart';

/// One fulfillment item quantity included in a shipment command.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminCreateShipmentItem with _$AdminCreateShipmentItem {
  /// Creates one shipped order-line quantity.
  const AdminCreateShipmentItem({required this.id, required this.quantity});

  /// Decodes one generated shipment-item command.
  factory AdminCreateShipmentItem.fromJson(Map<String, Object?> json) =>
      _$AdminCreateShipmentItemFromJson(json);

  /// Stable order-line identifier already owned by the fulfillment.
  final String id;

  /// Positive quantity being marked as shipped.
  final int quantity;
}

/// One carrier label submitted with a shipment.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminCreateShipmentLabel with _$AdminCreateShipmentLabel {
  /// Creates a safe carrier-label command.
  const AdminCreateShipmentLabel({
    required this.trackingNumber,
    required this.trackingUrl,
    required this.labelUrl,
  });

  /// Decodes one generated shipment-label command.
  factory AdminCreateShipmentLabel.fromJson(Map<String, Object?> json) =>
      _$AdminCreateShipmentLabelFromJson(json);

  /// Printable carrier label URL or Medusa's empty placeholder.
  final String labelUrl;

  /// Provider tracking identifier, which Medusa permits to be empty.
  final String trackingNumber;

  /// Carrier tracking URL or Medusa's empty placeholder.
  final String trackingUrl;
}

/// Atomic input for Medusa's create-order-shipment operation.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminCreateShipment with _$AdminCreateShipment {
  /// Creates one authenticated shipment command.
  const AdminCreateShipment({
    required this.items,
    required this.labels,
    required this.noNotification,
  });

  /// Decodes the generated Admin shipment request body.
  factory AdminCreateShipment.fromJson(Map<String, Object?> json) =>
      _$AdminCreateShipmentFromJson(json);

  /// Exact fulfillment-item quantities being shipped.
  final List<AdminCreateShipmentItem> items;

  /// Carrier tracking and printable-label links.
  final List<AdminCreateShipmentLabel> labels;

  /// Whether customer notification should be suppressed.
  final bool noNotification;
}
