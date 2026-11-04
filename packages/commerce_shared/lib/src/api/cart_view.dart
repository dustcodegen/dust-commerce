import 'package:commerce_shared/src/money.dart';
import 'package:commerce_shared/src/ordering/cart.dart';
import 'package:commerce_shared/src/ordering/shipping_option.dart';
import 'package:dust_dart/serde.dart';

part 'cart_view.g.dart';

/// A cart as a client sees it: the cart, and every total the server worked out.
///
/// This lives in the shared package rather than the server because it is a
/// contract, not an implementation. The server encodes this class and the
/// client decodes this class, so a field added here reaches both ends and a
/// field renamed breaks both at compile time — which is the point of the
/// whole repository.
///
/// The totals travel rather than being recomputed on the client. A storefront
/// that adds up its own lines will one day disagree with the receipt, and the
/// server's answer is the one the customer is charged.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
class CartView with _$CartView {
  /// Creates a [CartView].
  const CartView({
    required this.cart,
    required this.subtotal,
    required this.shippingTotal,
    required this.discountTotal,
    required this.tax,
    required this.total,
    required this.itemCount,
  });

  /// Builds the view of [cart], asking it for every total.
  factory CartView.of(Cart cart) => CartView(
        cart: cart,
        subtotal: cart.subtotal,
        shippingTotal: cart.shippingTotal,
        discountTotal: cart.discountTotal,
        tax: cart.tax,
        total: cart.total,
        itemCount: cart.itemCount,
      );

  /// Creates a [CartView] from JSON.
  factory CartView.fromJson(Map<String, Object?> json) =>
      _$CartViewFromJson(json);

  /// The cart itself.
  final Cart cart;

  /// What has been taken off the goods.
  final Money discountTotal;

  /// How many units are in the cart.
  final int itemCount;

  /// What delivery adds.
  final Money shippingTotal;

  /// The sum of the lines, before shipping, discount and tax.
  final Money subtotal;

  /// The tax the region charges.
  final Money tax;

  /// What the customer pays.
  final Money total;
}

/// The delivery options a cart may choose from.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
class ShippingOptionsView with _$ShippingOptionsView {
  /// Creates a [ShippingOptionsView].
  const ShippingOptionsView(
      {required this.shippingOptions, required this.count});

  /// Builds the view of [options].
  factory ShippingOptionsView.of(List<ShippingOption> options) =>
      ShippingOptionsView(shippingOptions: options, count: options.length);

  /// Creates a [ShippingOptionsView] from JSON.
  factory ShippingOptionsView.fromJson(Map<String, Object?> json) =>
      _$ShippingOptionsViewFromJson(json);

  /// How many there are.
  final int count;

  /// What is offered, cheapest first.
  final List<ShippingOption> shippingOptions;
}
