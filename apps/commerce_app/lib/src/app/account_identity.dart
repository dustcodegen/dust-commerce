part of 'commerce_app.dart';

extension on _CommerceAppState {
  /// Clears customer-owned state and claims a guest cart on identity changes.
  void _onAccountIdentityChanged() {
    final ownerId = _account.state.customer?.id;
    if (ownerId == _accountOwnerId) return;
    _accountOwnerId = ownerId;
    _addresses.reset();
    _orderDetail.reset();
    _orders.reset();
    _returnHistory.reset();
    _orderReturn.reset();
    _orderTransfer.reset();
    _checkout.reset();
    if (ownerId == null) {
      unawaited(_cart.clearForSignOut());
    } else {
      unawaited(_cart.transferToCustomer());
    }
  }
}
