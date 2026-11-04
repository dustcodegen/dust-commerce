part of 'checkout_view_model.dart';

/// Retry-safe order placement operations.
extension CheckoutPayment on CheckoutViewModel {
  /// Places, authorizes, and captures once; every server call is idempotent.
  Future<bool> placeOrder() async {
    if (state.isBusy) return false;
    final cart = args.cart.state.cart;
    if (!state.hasPaymentMethod) {
      return _fail('Complete every checkout step before placing your order.');
    }
    if (cart == null && state.order == null) {
      return _fail('Complete every checkout step before placing your order.');
    }
    _set(state.copyWith(
      status: CheckoutStatus.loading,
      operation: CheckoutOperation.place,
      message: null,
    ));
    try {
      final order = state.order ??
          await args.api.checkout(state.requestFor(cart!.cart.id));
      _set(state.copyWith(order: order));
      final guestEmail = order.customerId == null ? order.email : null;
      await args.api.authorizePayment(order.id, guestEmail: guestEmail);
      final paid = await args.api.capturePayment(
        order.id,
        guestEmail: guestEmail,
      );
      try {
        await args.receipts.write(paid);
      } on Object {
        // The in-memory receipt still completes the purchase safely.
      }
      await args.cart.finishCheckout();
      _set(CheckoutState(status: CheckoutStatus.complete, order: paid));
      return true;
    } on Object catch (error) {
      return _fail(_checkoutMessageOf(error));
    }
  }
}
