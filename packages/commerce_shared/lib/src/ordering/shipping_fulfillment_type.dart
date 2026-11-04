import 'package:dust_dart/serde.dart';

part 'shipping_fulfillment_type.g.dart';

/// How a customer receives a selected checkout option.
@Derive([Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
enum ShippingFulfillmentType {
  /// Merchant or carrier delivers the order.
  shipping,

  /// Customer collects the order from a named store.
  pickup,
}

/// Codec for embedding the fulfillment enum in server response objects.
final class ShippingFulfillmentTypeCodec
    implements SerDeCodec<ShippingFulfillmentType, Object?> {
  /// Creates the stateless wire codec.
  const ShippingFulfillmentTypeCodec();

  @override
  ShippingFulfillmentType deserialize(Object? value) =>
      _$ShippingFulfillmentTypeDeserialize(value);

  @override
  Object? serialize(ShippingFulfillmentType value) =>
      _$ShippingFulfillmentTypeSerialize(value);
}
