part of 'checkout_view_model.dart';

/// Order confirmation restoration operations.
extension CheckoutReceipt on CheckoutViewModel {
  /// Restores a confirmation from secure storage or the signed-in order API.
  Future<bool> loadReceipt(String orderId) async {
    if (state.order case final order? when order.id == orderId) return true;
    _set(state.copyWith(
      status: CheckoutStatus.loading,
      operation: CheckoutOperation.receipt,
      message: null,
    ));
    try {
      final local = await args.receipts.read(orderId);
      final order = local ??
          (args.currentCustomer() == null
              ? null
              : await args.api.order(orderId));
      if (order == null) return _fail('Order confirmation not found.');
      _set(CheckoutState(status: CheckoutStatus.complete, order: order));
      return true;
    } on Object catch (error) {
      return _fail(_checkoutMessageOf(error));
    }
  }
}
