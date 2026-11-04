import 'package:commerce_shared/src/money.dart';
import 'package:commerce_shared/src/ordering/shipping_fulfillment_type.dart';
import 'package:dust_dart/serde.dart';

part 'shipping_method.g.dart';

/// A way of getting the goods to the customer, and what it costs.
///
/// The amount is a snapshot, like a line item's price. A shipping option
/// repriced after a cart chose it must not change what that cart was quoted,
/// and the name is copied for the same reason: a customer should see on their
/// order the service they picked, under the name it had when they picked it.
@Derive([ToString(), Eq(), CopyWith(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
class ShippingMethod with _$ShippingMethod {
  /// Creates a [ShippingMethod] from an already-validated amount.
  const ShippingMethod({
    required this.optionId,
    required this.name,
    required this.amount,
    this.fulfillmentType = ShippingFulfillmentType.shipping,
    this.pickupAddress,
    this.pickupName,
  });

  /// Creates a [ShippingMethod], rejecting an amount below zero.
  ///
  /// Zero is allowed: free shipping is a thing a promotion grants, and a
  /// method costing nothing is different from no method at all.
  factory ShippingMethod.of({
    required String optionId,
    required String name,
    required Money amount,
    ShippingFulfillmentType fulfillmentType = ShippingFulfillmentType.shipping,
    String? pickupAddress,
    String? pickupName,
  }) {
    if (amount.isNegative) {
      throw ArgumentError.value(
        amount,
        'amount',
        'shipping cannot cost less than nothing',
      );
    }
    return ShippingMethod(
      optionId: optionId,
      name: name,
      amount: amount,
      fulfillmentType: fulfillmentType,
      pickupAddress: pickupAddress,
      pickupName: pickupName,
    );
  }

  /// Creates a [ShippingMethod] from JSON.
  factory ShippingMethod.fromJson(Map<String, Object?> json) =>
      _$ShippingMethodFromJson(json);

  /// What the customer is charged for delivery.
  final Money amount;

  /// Whether the customer receives or collects the order.
  final ShippingFulfillmentType fulfillmentType;

  /// The service name at the time of choosing.
  final String name;

  /// The option this was chosen from.
  final String optionId;

  /// Human-readable pickup address, present only for pickup methods.
  final String? pickupAddress;

  /// Store name shown above [pickupAddress], present only for pickup methods.
  final String? pickupName;
}
