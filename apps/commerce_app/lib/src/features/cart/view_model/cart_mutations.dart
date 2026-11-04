part of 'cart_view_model.dart';

/// Server-authoritative mutations kept beside the generated cart state owner.
extension CartMutations on CartViewModel {
  /// Moves the active cart to [regionId], accepting server repricing only.
  Future<bool> changeRegion(String regionId) async {
    final cart = state.cart;
    if (cart == null || cart.cart.region.id == regionId) return true;
    if (!_begin(CartOperation.region)) return false;
    try {
      final changed = await args.api.updateCartRegion(
        cart.cart.id,
        UpdateCartRegionBody(regionId: regionId),
      );
      return _succeed(changed, resetShippingOptions: true);
    } on Object catch (error) {
      _fail(CartOperation.region, error, cart: cart);
      return false;
    }
  }

  /// Retains checkout addresses and accepts only the server response.
  Future<bool> saveAddresses(UpdateCartAddressesBody body) => _change(
        CartOperation.address,
        request: (id) => args.api.updateCartAddresses(id, body),
      );

  /// Replaces one line quantity after the server rechecks inventory.
  Future<bool> updateQuantity(String lineId, int quantity) => _change(
        CartOperation.update,
        lineId: lineId,
        request: (id) => args.api.updateLine(
          id,
          lineId,
          UpdateLineBody(quantity: quantity),
        ),
      );

  /// Removes one line and accepts only the server's updated totals.
  Future<bool> remove(String lineId) => _change(
        CartOperation.remove,
        lineId: lineId,
        request: (id) => args.api.removeLine(id, lineId),
      );

  /// Loads delivery choices for the current cart.
  Future<bool> loadShippingOptions() async {
    final cart = state.cart;
    if (cart == null || !_begin(CartOperation.shipping)) return false;
    try {
      final view = await args.api.shippingOptions(cart.cart.id);
      _setShippingOptions(cart, view.shippingOptions);
      return true;
    } on Object catch (error) {
      _fail(CartOperation.shipping, error, cart: cart);
      return false;
    }
  }

  /// Selects delivery and accepts only the server's updated totals.
  Future<bool> chooseShipping(String optionId) => _change(
        CartOperation.shipping,
        request: (id) => args.api.chooseShipping(
          id,
          ChooseShippingBody(optionId: optionId),
        ),
      );

  /// Retains payment selection and accepts only the server's updated cart.
  Future<bool> choosePayment(String providerId) => _change(
        CartOperation.payment,
        request: (id) => args.api.choosePayment(
          id,
          ChoosePaymentBody(providerId: providerId),
        ),
      );

  /// Applies a promotion and accepts only the server's updated totals.
  Future<bool> applyPromotion(String code) => _change(
        CartOperation.promotion,
        request: (id) => args.api.applyPromotion(
          id,
          ApplyPromotionBody(code: code.trim()),
        ),
      );

  /// Removes the current promotion and accepts the server's totals.
  Future<bool> removePromotion() => _change(
        CartOperation.promotion,
        request: args.api.removePromotion,
      );

  Future<bool> _change(
    CartOperation operation, {
    String? lineId,
    required Future<CartView> Function(String cartId) request,
  }) async {
    final cart = state.cart;
    if (cart == null || !_begin(operation, lineId: lineId)) return false;
    try {
      return _succeed(await request(cart.cart.id));
    } on Object catch (error) {
      _fail(operation, error, cart: cart, lineId: lineId);
      return false;
    }
  }
}
