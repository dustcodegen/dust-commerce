import 'package:commerce_app/src/features/checkout/model/checkout_address_draft.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_dart/derive.dart';

part 'checkout_state.g.dart';

/// Checkout network lifecycle visible to the customer.
enum CheckoutStatus {
  /// The checkout has not inspected its cart yet.
  idle,

  /// The current step is editable.
  ready,

  /// A server operation is running.
  loading,

  /// A paid receipt is ready.
  complete,

  /// The latest operation failed without losing prior input.
  failed,
}

/// The operation currently running or most recently failed.
enum CheckoutOperation {
  /// Address preparation or validation.
  prepare,

  /// Delivery loading or selection.
  delivery,

  /// Payment method selection.
  payment,

  /// Order placement and payment capture.
  place,

  /// Confirmation receipt restoration.
  receipt,
}

/// Durable state shared by checkout steps and the confirmation route.
@Derive([ToString(), Eq(), CopyWith()])
final class CheckoutState with _$CheckoutState {
  /// Creates checkout state.
  const CheckoutState({
    this.status = CheckoutStatus.idle,
    this.operation,
    this.shipping = const CheckoutAddressDraft(),
    this.billing = const CheckoutAddressDraft(),
    this.sameAsBilling = true,
    this.email = '',
    this.paymentMethod = const None(),
    this.paymentProviders = const [],
    this.paymentProvidersLoaded = false,
    this.order,
    this.message,
  });

  /// Separate invoice address values when requested.
  final CheckoutAddressDraft billing;

  /// Receipt and contact email.
  final String email;

  /// Display-safe failure message.
  final String? message;

  /// Operation in flight or most recently failed.
  final CheckoutOperation? operation;

  /// Order retained after checkout begins, making retries resumable.
  final Order? order;

  /// Explicitly selected provider identifier.
  final Option<String> paymentMethod;

  /// Providers the cart's selling region currently offers.
  final List<PaymentProviderView> paymentProviders;

  /// Whether provider discovery completed, including a valid empty result.
  final bool paymentProvidersLoaded;

  /// Whether billing reuses the shipping destination.
  final bool sameAsBilling;

  /// Delivery-address draft.
  final CheckoutAddressDraft shipping;

  /// Current checkout lifecycle.
  final CheckoutStatus status;

  /// Whether a checkout request is in flight.
  bool get isBusy => status == CheckoutStatus.loading;

  /// Whether any server-retained payment provider is selected.
  bool get hasPaymentMethod => switch (paymentMethod) {
        Some() => true,
        None() => false,
      };

  /// Whether the retained choice remains in the latest regional listing.
  bool get hasAvailablePaymentMethod =>
      paymentProviders.any((provider) => isPaymentSelected(provider.id));

  /// Whether [providerId] is the server-retained selection.
  bool isPaymentSelected(String providerId) =>
      paymentMethod == Some<String>(providerId);

  /// Validated request made from the values the customer reviewed.
  CheckoutRequest requestFor(String cartId) => CheckoutRequest(
        cartId: cartId,
        email: email.trim(),
        shippingAddress: shipping.toInput(),
        billingAddress: sameAsBilling ? null : billing.toInput(),
      );
}
