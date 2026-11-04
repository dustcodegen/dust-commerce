import 'package:dust_dart/db.dart';

/// Stable reasons a checkout can be refused without a storage failure.
enum CheckoutFailure {
  /// No active cart exists for the supplied id.
  noCart,

  /// The cart contains no lines.
  emptyCart,

  /// A managed variant no longer has enough stock.
  outOfStock,

  /// The cart belongs to a different authenticated customer.
  wrongCustomer,

  /// A destination is outside the cart's selling region.
  countryNotInRegion,

  /// No delivery method was selected for a physical cart.
  shippingNotSelected,

  /// No enabled payment provider was selected.
  paymentNotSelected,
}

/// One flat error channel for checkout rules and storage failures.
sealed class CheckoutError {
  const CheckoutError();
}

/// Expected checkout refusal safe for transport mapping.
final class CheckoutRejected extends CheckoutError {
  /// Creates a refusal with its stable reason.
  const CheckoutRejected(this.failure);

  /// Business rule that refused checkout.
  final CheckoutFailure failure;
}

/// SQLx failure retained while transport returns a safe response.
final class CheckoutStorage extends CheckoutError {
  /// Wraps the original database cause.
  const CheckoutStorage(this.cause);

  /// Original storage failure.
  final SqlxError cause;
}
