import 'package:commerce_shared/src/money.dart';
import 'package:commerce_shared/src/customers/address.dart';
import 'package:commerce_shared/src/ordering/cart_payment_session.dart';
import 'package:commerce_shared/src/ordering/line_item.dart';
import 'package:commerce_shared/src/ordering/promotion.dart';
import 'package:commerce_shared/src/ordering/shipping_method.dart';
import 'package:commerce_shared/src/region.dart';
import 'package:dust_dart/serde.dart';

part 'cart.g.dart';
part 'cart_operations.dart';

/// The lines a customer has chosen, in one region's currency.
///
/// The region is part of the cart's identity rather than a lookup at
/// checkout: it fixes the currency every line must be priced in and the tax
/// rule the total is computed under. A cart that decided those at the end
/// could total differently from what it displayed all the way through.
@Derive([ToString(), Eq(), CopyWith(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
class Cart with _$Cart {
  /// Creates a [Cart] from already-validated values.
  const Cart({
    required this.id,
    required this.region,
    required this.items,
    this.promotions = const [],
    this.email,
    this.customerId,
    this.shippingAddress,
    this.billingAddress,
    this.shippingMethod,
    this.paymentSession,
  });

  /// Creates a [Cart], rejecting lines that do not belong in it.
  ///
  /// Throws [ArgumentError] when two lines share an id, or when a line is
  /// priced in a currency other than the region's.
  factory Cart.of({
    required String id,
    required Region region,
    List<LineItem> items = const [],
    String? email,
    String? customerId,
    Address? shippingAddress,
    Address? billingAddress,
    ShippingMethod? shippingMethod,
    CartPaymentSession? paymentSession,
    List<CartPromotion> promotions = const [],
  }) {
    final ids = items.map((item) => item.id).toList();
    if (ids.toSet().length != ids.length) {
      throw ArgumentError.value(items, 'items', 'duplicate line id');
    }
    for (final item in items) {
      if (item.unitPrice.currencyCode != region.currencyCode) {
        throw ArgumentError.value(
          item.unitPrice.currencyCode,
          'items',
          'line ${item.id} is not priced in ${region.currencyCode}',
        );
      }
    }
    if (shippingMethod != null &&
        shippingMethod.amount.currencyCode != region.currencyCode) {
      throw ArgumentError.value(
        shippingMethod.amount.currencyCode,
        'shippingMethod',
        'shipping is not priced in ${region.currencyCode}',
      );
    }
    final promotionIds = promotions.map((promotion) => promotion.id).toList();
    if (promotionIds.toSet().length != promotionIds.length) {
      throw ArgumentError.value(
        promotions,
        'promotions',
        'duplicate applied promotion id',
      );
    }
    for (final promotion in promotions) {
      if (promotion.amount.currencyCode != region.currencyCode) {
        throw ArgumentError.value(
          promotion.amount.currencyCode,
          'promotions',
          'promotion ${promotion.code} is not priced in ${region.currencyCode}',
        );
      }
      if (promotion.amount.isNegative) {
        throw ArgumentError.value(
          promotion.amount,
          'promotions',
          'a negative discount is a surcharge, which this is not',
        );
      }
    }
    return Cart(
      id: id,
      region: region,
      items: items,
      email: email,
      customerId: customerId,
      shippingAddress: shippingAddress,
      billingAddress: billingAddress,
      shippingMethod: shippingMethod,
      paymentSession: paymentSession,
      promotions: List.unmodifiable(promotions),
    );
  }

  /// Creates a [Cart] from JSON.
  factory Cart.fromJson(Map<String, Object?> json) => _$CartFromJson(json);

  /// The customer this cart belongs to, once known.
  final String? customerId;

  /// Separate invoice destination, absent when shipping is reused.
  final Address? billingAddress;

  /// Contact address, which a guest checkout collects before an account.
  final String? email;

  /// Unique identifier.
  final String id;

  /// The chosen lines.
  final List<LineItem> items;

  /// Customer-facing snapshots of promotions already applied to this cart.
  final List<CartPromotion> promotions;

  /// Public payment provider choice retained across checkout reloads.
  final CartPaymentSession? paymentSession;

  /// The selling territory, fixing currency and tax.
  final Region region;

  /// Delivery destination retained before the cart becomes an order.
  final Address? shippingAddress;

  /// How the goods are to be delivered, once chosen.
  final ShippingMethod? shippingMethod;
}
