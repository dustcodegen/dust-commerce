import 'package:dust_dart/db.dart';

part 'create_shipment_model.g.dart';

/// Lifecycle facts required to authorize one shipment mutation.
@Derive([FromRow()])
final class AdminShipmentTarget {
  /// Creates the direct SQLx shipment target.
  const AdminShipmentTarget({
    required this.requiresShipping,
    required this.canceled,
    required this.shipped,
    required this.delivered,
  });

  /// Whether this fulfillment has already been canceled.
  final bool canceled;

  /// Whether this fulfillment has already been delivered.
  final bool delivered;

  /// Whether this fulfillment represents physical shipping.
  @Sqlx(rename: 'requires_shipping')
  final bool requiresShipping;

  /// Whether this fulfillment has already been shipped.
  final bool shipped;
}

/// Frozen item quantity read directly from one fulfillment.
@Derive([FromRow()])
final class AdminShipmentStoredItem {
  /// Creates one direct SQLx shipment-item projection.
  const AdminShipmentStoredItem({required this.id, required this.quantity});

  /// Original order-line identifier.
  final String id;

  /// Exact quantity frozen into the fulfillment.
  final int quantity;
}

/// Existing label tuple used to preserve provider-created labels once.
@Derive([FromRow()])
final class AdminShipmentStoredLabel {
  /// Creates one direct SQLx label tuple.
  const AdminShipmentStoredLabel({
    required this.trackingNumber,
    required this.trackingUrl,
    required this.labelUrl,
  });

  /// Printable label URL or placeholder.
  @Sqlx(rename: 'label_url')
  final String labelUrl;

  /// Carrier tracking identifier.
  @Sqlx(rename: 'tracking_number')
  final String trackingNumber;

  /// Carrier tracking URL or placeholder.
  @Sqlx(rename: 'tracking_url')
  final String trackingUrl;
}
