import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_dart/serde.dart';

part 'cart_state.g.dart';

/// The cart operation currently visible to the storefront.
enum CartStatus {
  /// No cart operation has started.
  idle,

  /// A cart request is in flight.
  loading,

  /// The latest cart request completed.
  ready,

  /// The latest cart request failed.
  failed,
}

/// The cart action whose progress the storefront is showing.
enum CartOperation {
  /// Creating a cart from an external checkout permalink.
  buy,

  /// Restoring the persisted cart capability.
  restore,

  /// Adding a selected variant.
  add,

  /// Replacing one line quantity.
  update,

  /// Removing one line.
  remove,

  /// Applying or removing a promotion.
  promotion,

  /// Loading or choosing delivery.
  shipping,

  /// Retaining the checkout payment provider.
  payment,

  /// Retaining checkout contact and destinations.
  address,

  /// Moving the cart to another selling region.
  region,

  /// Claiming the guest cart after customer authentication.
  transfer,
}

/// Display-safe reason the guest cart could not be transferred.
enum CartTransferFailure {
  /// The customer session is no longer accepted.
  unauthorized,

  /// The transfer service could not complete the request.
  unavailable,
}

/// The single cart shared by navigation, product actions, and checkout.
@Derive([ToString(), Eq(), CopyWith()])
class CartState with _$CartState {
  /// Creates cart state.
  const CartState({
    this.status = CartStatus.idle,
    this.cart,
    this.message,
    this.operation,
    this.activeLineId,
    this.shippingOptions = const [],
    this.transferFailure = const None(),
    this.dismissedFreeShippingCartId = const None(),
  });

  /// The server-computed cart and totals, once created.
  final CartView? cart;

  /// Line being updated or removed, when the action is line-scoped.
  final String? activeLineId;

  /// A display-safe operation failure.
  final String? message;

  /// The operation currently in flight or most recently failed.
  final CartOperation? operation;

  /// Delivery choices returned by the server for the current cart.
  final List<ShippingOption> shippingOptions;

  /// The operation currently in flight.
  final CartStatus status;

  /// Why the current guest cart remains unclaimed, when known.
  final Option<CartTransferFailure> transferFailure;

  /// Cart whose free-shipping popup the customer dismissed this session.
  final Option<String> dismissedFreeShippingCartId;

  /// Quantity shown in navigation.
  int get itemCount => cart?.itemCount ?? 0;

  /// Whether the customer closed the popup for [cartId] this session.
  bool isFreeShippingNudgeDismissedFor(String cartId) =>
      dismissedFreeShippingCartId.match(
        some: (dismissedId) => dismissedId == cartId,
        none: () => false,
      );
}
