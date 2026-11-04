import 'package:commerce_server/src/features/cart/model/cart.dart';
import 'package:commerce_server/src/features/cart/model/shipping.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_dart/serde.dart';

part 'view.g.dart';

/// Explicit cart envelope including authoritative totals.
@Derive([Serialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class CartViewResponse with _$CartViewResponse {
  /// Builds the envelope from one explicit cart response.
  CartViewResponse.of(this.cart)
      : subtotal = cart.subtotal,
        shippingTotal = cart.shippingTotal,
        discountTotal = cart.discountTotal,
        tax = cart.tax,
        total = cart.total,
        itemCount = cart.itemCount;

  /// Explicit cart response.
  final CartResponse cart;

  /// Discount applied to the goods.
  final Money discountTotal;

  /// Number of units in the cart.
  final int itemCount;

  /// Selected delivery amount.
  final Money shippingTotal;

  /// Sum of all cart lines.
  final Money subtotal;

  /// Region tax amount.
  final Money tax;

  /// Final amount to charge.
  final Money total;
}

/// Explicit shipping-options envelope.
@Derive([Serialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class ShippingOptionsResponse with _$ShippingOptionsResponse {
  /// Builds the envelope from explicit shipping methods.
  ShippingOptionsResponse.of(this.shippingOptions)
      : count = shippingOptions.length;

  /// Number of available methods.
  final int count;

  /// Explicit available shipping methods.
  final List<ShippingOptionResponse> shippingOptions;
}
