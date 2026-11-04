import 'package:dust_dart/serde.dart';

part 'order_fulfillment_status.g.dart';

/// Customer-visible progress of physical order fulfillment.
@Derive([Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
enum OrderFulfillmentStatus {
  /// No active fulfillment contains an ordered unit.
  notFulfilled,

  /// Some, but not all, ordered units have a fulfillment.
  partiallyFulfilled,

  /// Every ordered unit has an active fulfillment.
  fulfilled,

  /// Some, but not all, ordered units have shipped.
  partiallyShipped,

  /// Every ordered unit has shipped.
  shipped,

  /// Some, but not all, ordered units have been delivered.
  partiallyDelivered,

  /// Every ordered unit has been delivered.
  delivered,

  /// Fulfillment was canceled without an active replacement.
  canceled,
}

/// Codec for embedding the Store fulfillment enum in larger responses.
final class OrderFulfillmentStatusCodec
    implements SerDeCodec<OrderFulfillmentStatus, Object?> {
  /// Creates the stateless wire codec.
  const OrderFulfillmentStatusCodec();

  @override
  OrderFulfillmentStatus deserialize(Object? value) =>
      _$OrderFulfillmentStatusDeserialize(value);

  @override
  Object? serialize(OrderFulfillmentStatus value) =>
      _$OrderFulfillmentStatusSerialize(value);
}
