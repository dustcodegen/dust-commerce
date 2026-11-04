import 'package:dust_dart/serde.dart';

part 'admin_order_status.g.dart';

/// Merchant-visible order lifecycle values supported by this schema.
@Derive([Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
enum AdminOrderStatus {
  /// Placed and still open.
  pending,

  /// Successfully paid and completed.
  completed,

  /// Called off before completion.
  canceled,

  /// Removed from active operations after reaching an eligible final state.
  archived,
}

/// Merchant-visible payment state frozen on the order.
@Derive([Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
enum AdminOrderPaymentStatus {
  /// Payment has not yet been captured.
  awaiting,

  /// The complete order total was captured.
  captured,

  /// Captured funds were returned.
  refunded,
}

/// Merchant-visible fulfillment state matching Medusa's order lifecycle.
@Derive([Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
enum AdminOrderFulfillmentStatus {
  /// No fulfilment has been created for the order.
  notFulfilled,

  /// Some, but not all, order quantities have fulfillment records.
  partiallyFulfilled,

  /// Every order quantity has an active fulfillment record.
  fulfilled,

  /// Some, but not all, order quantities have shipped.
  partiallyShipped,

  /// Every order quantity has shipped.
  shipped,

  /// Some, but not all, order quantities have been delivered.
  partiallyDelivered,

  /// Every order quantity has been delivered.
  delivered,

  /// Fulfillment was canceled without an active replacement.
  canceled,
}

/// Persistence lifecycle of the order's provider payment collection.
@Derive([Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
enum AdminOrderPaymentRecordStatus {
  /// A provider attempt has not yet authorized funds.
  pending,

  /// Funds are authorized but not captured.
  authorized,

  /// Funds have been captured.
  captured,

  /// The provider attempt was canceled.
  canceled,

  /// The provider attempt failed.
  failed,
}

/// Codec used by direct server projections for order lifecycle values.
final class AdminOrderStatusCodec
    implements SerDeCodec<AdminOrderStatus, String> {
  /// Creates the stateless codec.
  const AdminOrderStatusCodec();

  @override
  AdminOrderStatus deserialize(String value) =>
      AdminOrderStatus.values.byName(value);

  @override
  String serialize(AdminOrderStatus value) => value.name;
}

/// Codec used by direct server projections for payment state.
final class AdminOrderPaymentStatusCodec
    implements SerDeCodec<AdminOrderPaymentStatus, String> {
  /// Creates the stateless codec.
  const AdminOrderPaymentStatusCodec();

  @override
  AdminOrderPaymentStatus deserialize(String value) =>
      AdminOrderPaymentStatus.values.byName(value);

  @override
  String serialize(AdminOrderPaymentStatus value) => value.name;
}

/// Codec used by direct server projections for provider payment state.
final class AdminOrderPaymentRecordStatusCodec
    implements SerDeCodec<AdminOrderPaymentRecordStatus, String> {
  /// Creates the stateless codec.
  const AdminOrderPaymentRecordStatusCodec();

  @override
  AdminOrderPaymentRecordStatus deserialize(String value) =>
      AdminOrderPaymentRecordStatus.values.byName(value);

  @override
  String serialize(AdminOrderPaymentRecordStatus value) => value.name;
}

/// Codec used by direct server projections for fulfilment state.
final class AdminOrderFulfillmentStatusCodec
    implements SerDeCodec<AdminOrderFulfillmentStatus, String> {
  /// Creates the stateless codec.
  const AdminOrderFulfillmentStatusCodec();

  @override
  AdminOrderFulfillmentStatus deserialize(String value) => switch (value) {
        'not_fulfilled' => AdminOrderFulfillmentStatus.notFulfilled,
        'partially_fulfilled' => AdminOrderFulfillmentStatus.partiallyFulfilled,
        'fulfilled' => AdminOrderFulfillmentStatus.fulfilled,
        'partially_shipped' => AdminOrderFulfillmentStatus.partiallyShipped,
        'shipped' => AdminOrderFulfillmentStatus.shipped,
        'partially_delivered' => AdminOrderFulfillmentStatus.partiallyDelivered,
        'delivered' => AdminOrderFulfillmentStatus.delivered,
        'canceled' => AdminOrderFulfillmentStatus.canceled,
        _ => throw ArgumentError.value(value, 'value', 'Unknown fulfillment'),
      };

  @override
  String serialize(AdminOrderFulfillmentStatus value) => switch (value) {
        AdminOrderFulfillmentStatus.notFulfilled => 'not_fulfilled',
        AdminOrderFulfillmentStatus.partiallyFulfilled => 'partially_fulfilled',
        AdminOrderFulfillmentStatus.fulfilled => 'fulfilled',
        AdminOrderFulfillmentStatus.partiallyShipped => 'partially_shipped',
        AdminOrderFulfillmentStatus.shipped => 'shipped',
        AdminOrderFulfillmentStatus.partiallyDelivered => 'partially_delivered',
        AdminOrderFulfillmentStatus.delivered => 'delivered',
        AdminOrderFulfillmentStatus.canceled => 'canceled',
      };
}
