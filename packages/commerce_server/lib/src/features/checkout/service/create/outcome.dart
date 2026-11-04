import 'package:commerce_server/src/features/checkout/failure.dart';
import 'package:commerce_server/src/features/checkout/model.dart';

/// Transaction outcome keeps business refusal outside SQLx's error channel.
sealed class CheckoutPlacementOutcome {
  const CheckoutPlacementOutcome();
}

/// Successful committed order.
final class CheckoutPlacementReady extends CheckoutPlacementOutcome {
  /// Creates a successful placement outcome.
  const CheckoutPlacementReady(this.order);

  /// Direct SQLx order response.
  final OrderResponse order;
}

/// Expected refusal that causes the transaction to commit no order.
final class CheckoutPlacementDenied extends CheckoutPlacementOutcome {
  /// Creates a denied placement outcome.
  const CheckoutPlacementDenied(this.failure);

  /// Stable checkout refusal.
  final CheckoutFailure failure;
}

/// No active cart outcome.
const checkoutNoCart = CheckoutPlacementDenied(CheckoutFailure.noCart);

/// Empty cart outcome.
const checkoutEmptyCart = CheckoutPlacementDenied(CheckoutFailure.emptyCart);

/// Managed stock conflict outcome.
const checkoutOutOfStock = CheckoutPlacementDenied(CheckoutFailure.outOfStock);

/// Foreign cart ownership outcome.
const checkoutWrongCustomer =
    CheckoutPlacementDenied(CheckoutFailure.wrongCustomer);

/// Unsupported destination outcome.
const checkoutCountryNotInRegion =
    CheckoutPlacementDenied(CheckoutFailure.countryNotInRegion);

/// Missing delivery choice outcome.
const checkoutShippingNotSelected =
    CheckoutPlacementDenied(CheckoutFailure.shippingNotSelected);

/// Missing or disabled payment choice outcome.
const checkoutPaymentNotSelected =
    CheckoutPlacementDenied(CheckoutFailure.paymentNotSelected);
