part of 'cart_view_model.dart';

/// Creates one server-authoritative cart from a checkout permalink.
extension CartBuy on CartViewModel {
  /// Replaces the local cart capability only after the atomic server write.
  Future<bool> buy(BuyCartBody body) async {
    if (!_begin(CartOperation.buy)) return false;
    try {
      final cart = await args.api.createCartWithItems(body);
      await args.cartIds.write(args.storageScope, cart.cart.id);
      return _succeed(cart, resetShippingOptions: true);
    } on Object catch (error) {
      _fail(CartOperation.buy, error, cart: state.cart);
      return false;
    }
  }
}
