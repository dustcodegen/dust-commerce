part of 'cart_view_model.dart';

/// Customer-session ownership changes for the active cart capability.
extension CartTransfer on CartViewModel {
  /// Claims the active guest cart after authentication.
  ///
  /// The endpoint is idempotent, so retrying after a lost response is safe.
  Future<bool> transferToCustomer() {
    final active = _transferTask;
    if (active != null) return active;
    final task = _transferToCustomer();
    _transferTask = task;
    return task.whenComplete(() => _transferTask = null);
  }

  Future<bool> _transferToCustomer() async {
    final revision = ++_identityRevision;
    await restore();
    final current = state.cart;
    if (revision != _identityRevision || current == null) return true;
    if (current.cart.customerId != null) return true;
    if (!_begin(CartOperation.transfer)) return false;
    try {
      final transferred = await args.api.transferCart(current.cart.id);
      if (revision != _identityRevision) return false;
      return _succeed(transferred);
    } on Object catch (error) {
      if (revision != _identityRevision) return false;
      _fail(CartOperation.transfer, error, cart: current);
      return false;
    }
  }

  /// Removes a customer cart from this device after sign-out.
  Future<void> clearForSignOut() async {
    _identityRevision++;
    try {
      await args.cartIds.clear(args.storageScope);
    } finally {
      _clearForIdentity();
    }
  }
}
