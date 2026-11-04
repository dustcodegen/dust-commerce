import 'package:commerce_shared/src/customers/address.dart';
import 'package:commerce_shared/src/money.dart';
import 'package:commerce_shared/src/ordering/cart.dart';
import 'package:commerce_shared/src/ordering/order_line_item.dart';
import 'package:commerce_shared/src/ordering/order_fulfillment_status.dart';
import 'package:commerce_shared/src/ordering/shipping_method.dart';
import 'package:commerce_shared/src/region.dart';
import 'package:dust_dart/serde.dart';

part 'order.g.dart';
part 'order_values.dart';

/// Where an order sits in its lifecycle.
@Derive([Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
enum OrderStatus {
  /// Placed and not yet completed, independent of payment state.
  pending,

  /// Explicitly completed after its post-purchase work finishes.
  completed,

  /// Called off before completion.
  canceled,

  /// Removed from active operations after reaching an eligible final state.
  archived,
}

/// Whether the money has moved.
@Derive([Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
enum PaymentStatus {
  /// Placed, nothing taken.
  awaiting,

  /// Funds taken.
  captured,

  /// Funds returned.
  refunded,
}

/// Public payment facts needed to explain a paid order to its buyer.
/// Provider metadata and credentials stay server-side.
@Derive([ToString(), Eq(), CopyWith(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
class OrderPayment with _$OrderPayment {
  /// Creates a safe payment receipt.
  const OrderPayment({
    required this.providerId,
    required this.amount,
    required this.createdAt,
  });

  /// Creates a payment receipt from JSON.
  factory OrderPayment.fromJson(Map<String, Object?> json) =>
      _$OrderPaymentFromJson(json);

  /// Amount authorised against the frozen order total.
  final Money amount;

  /// When the provider payment record was created.
  final DateTime createdAt;

  /// Public adapter identifier used to select its display treatment.
  final String providerId;
}

/// A cart, frozen at the moment it was placed.
/// Amounts and region are frozen so later catalogue changes cannot alter it.
@Derive([ToString(), Eq(), CopyWith(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
class Order with _$Order {
  /// Creates an [Order] from already-frozen values.
  const Order({
    required this.id,
    required this.displayId,
    required this.email,
    required this.region,
    required this.items,
    required this.subtotal,
    required this.shippingTotal,
    required this.discountTotal,
    required this.tax,
    required this.total,
    required this.shippingAddress,
    required this.billingAddress,
    required this.placedAt,
    this.customerId,
    this.payment,
    this.shippingMethod,
    this.status = OrderStatus.pending,
    this.fulfillmentStatus = OrderFulfillmentStatus.notFulfilled,
    this.paymentStatus = PaymentStatus.awaiting,
  });

  /// Places [cart] as an order, freezing its lines and totals.
  /// Throws [ArgumentError] when the cart is empty or carries no email.
  factory Order.fromCart({
    required String id,
    required int displayId,
    required Cart cart,
    required Address shippingAddress,
    required DateTime placedAt,
    Address? billingAddress,
  }) =>
      _orderFromCart(
        id: id,
        displayId: displayId,
        cart: cart,
        shippingAddress: shippingAddress,
        billingAddress: billingAddress,
        placedAt: placedAt,
      );

  /// Creates an [Order] from JSON.
  factory Order.fromJson(Map<String, Object?> json) => _$OrderFromJson(json);

  /// Where the invoice goes.
  final Address billingAddress;

  /// The account that placed this, when there was one.
  final String? customerId;

  /// Contact address for the buyer.
  final String email;

  /// Short monotonically increasing identifier shown to people.
  final int displayId;

  /// Unique identifier.
  final String id;

  /// Real progress derived from active fulfillment records.
  @SerDe(
    defaultValue: OrderFulfillmentStatus.notFulfilled,
    using: OrderFulfillmentStatusCodec(),
  )
  final OrderFulfillmentStatus fulfillmentStatus;

  /// The lines as they stood at checkout.
  final List<OrderLineItem> items;

  /// Whether the money has moved.
  final PaymentStatus paymentStatus;

  /// Safe provider receipt once a payment has been started.
  final OrderPayment? payment;

  /// When this was placed.
  final DateTime placedAt;

  /// The territory it was sold under, kept for the record.
  final Region region;

  /// Where the goods go.
  final Address shippingAddress;

  /// Lifecycle state.
  final OrderStatus status;

  /// The frozen amount taken off the goods.
  final Money discountTotal;

  /// The delivery service chosen, under the name it had.
  final ShippingMethod? shippingMethod;

  /// The frozen cost of delivery.
  final Money shippingTotal;

  /// The frozen sum of the lines, before shipping, discount and tax.
  final Money subtotal;

  /// The frozen tax.
  final Money tax;

  /// The frozen amount charged.
  final Money total;
}
