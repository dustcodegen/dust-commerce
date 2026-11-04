import 'package:commerce_app/src/core/api/api.dart';
import 'package:commerce_app/src/core/storage/storage.dart';
import 'package:commerce_app/src/features/cart/view_model/cart_view_model.dart';
import 'package:commerce_app/src/features/checkout/model/model.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dio/dio.dart';
import 'package:dust_dart/derive.dart';
import 'package:dust_flutter/state.dart';

part 'checkout_view_model.g.dart';
part 'checkout_error.dart';
part 'checkout_payment.dart';
part 'checkout_receipt.dart';

/// Dependencies for checkout and the immediately following receipt.
final class CheckoutViewModelArgs extends ViewModelArgs {
  /// Creates checkout dependencies.
  const CheckoutViewModelArgs({
    required this.api,
    required this.cart,
    required this.receipts,
    required this.currentCustomer,
    super.observer,
  });

  /// Generated storefront client.
  final CommerceApi api;

  /// Shared server-authoritative cart owner.
  final CartViewModel cart;

  /// Reads the currently proven customer without copying auth state.
  final Customer? Function() currentCustomer;

  /// Secure guest-receipt persistence.
  final OrderReceiptStore receipts;
}

/// Owns the resumable address-to-paid-order workflow.
@ViewModel(state: CheckoutState, args: CheckoutViewModelArgs)
final class CheckoutViewModel extends $CheckoutViewModel {
  /// Creates the checkout view model.
  CheckoutViewModel(super.args);

  /// Clears customer-derived checkout input when account ownership changes.
  void reset() => emit(const CheckoutState());

  /// Restores a new checkout from the server-owned cart address step.
  void prepare() {
    if (state.status != CheckoutStatus.idle) return;
    final view = args.cart.state.cart;
    if (view == null || view.cart.isEmpty) return;
    final customer = args.currentCustomer();
    final shipping = view.cart.shippingAddress;
    final billing = view.cart.billingAddress;
    emit(CheckoutState(
      status: CheckoutStatus.ready,
      email: customer?.email ?? view.cart.email ?? '',
      shipping: shipping == null
          ? const CheckoutAddressDraft()
          : CheckoutAddressDraft.fromAddress(shipping),
      billing: billing == null
          ? const CheckoutAddressDraft()
          : CheckoutAddressDraft.fromAddress(billing),
      sameAsBilling: billing == null,
      paymentMethod: switch (view.cart.paymentSession?.providerId) {
        final provider? => Some(provider),
        null => const None(),
      },
    ));
  }

  /// Validates and persists address input before delivery selection.
  Future<bool> saveAddresses({
    required String email,
    required CheckoutAddressDraft shipping,
    required CheckoutAddressDraft billing,
    required bool sameAsBilling,
  }) async {
    final cartId = args.cart.state.cart?.cart.id;
    final next = state.copyWith(
      status: CheckoutStatus.ready,
      operation: CheckoutOperation.prepare,
      email: email.trim(),
      shipping: shipping,
      billing: billing,
      sameAsBilling: sameAsBilling,
      message: null,
    );
    if (cartId == null) {
      emit(next.copyWith(
        status: CheckoutStatus.failed,
        message: 'Your cart is no longer available.',
      ));
      return false;
    }
    final validation = next.requestFor(cartId).validate();
    if (validation case Invalid(:final errors)) {
      emit(next.copyWith(
        status: CheckoutStatus.failed,
        message: errors.first.message,
      ));
      return false;
    }
    emit(next.copyWith(status: CheckoutStatus.loading));
    final saved = await args.cart.saveAddresses(UpdateCartAddressesBody(
      email: next.email,
      shippingAddress: next.shipping.toInput(),
      billingAddress: next.sameAsBilling ? null : next.billing.toInput(),
    ));
    if (!saved) return _cartFailure();
    emit(next);
    return true;
  }

  /// Loads server-priced delivery choices without losing the address draft.
  Future<bool> loadDelivery() async {
    if (state.isBusy) return false;
    emit(state.copyWith(
      status: CheckoutStatus.loading,
      operation: CheckoutOperation.delivery,
      message: null,
    ));
    final loaded = await args.cart.loadShippingOptions();
    if (!loaded) return _cartFailure();
    emit(state.copyWith(status: CheckoutStatus.ready, message: null));
    return true;
  }

  /// Selects one authoritative shipping option.
  Future<bool> chooseDelivery(String optionId) async {
    if (state.isBusy) return false;
    emit(state.copyWith(
      status: CheckoutStatus.loading,
      operation: CheckoutOperation.delivery,
      message: null,
    ));
    final selected = await args.cart.chooseShipping(optionId);
    if (!selected) return _cartFailure();
    emit(state.copyWith(status: CheckoutStatus.ready, message: null));
    return true;
  }

  /// Loads the payment providers enabled for this cart's selling region.
  Future<bool> loadPaymentMethods() async {
    if (state.isBusy || state.paymentProvidersLoaded) return false;
    final regionId = args.cart.state.cart?.cart.region.id;
    if (regionId == null) {
      return _fail('Your cart is no longer available.');
    }
    emit(state.copyWith(
      status: CheckoutStatus.loading,
      operation: CheckoutOperation.payment,
      message: null,
    ));
    try {
      final result = await args.api.paymentProviders(regionId);
      emit(state.copyWith(
        status: CheckoutStatus.ready,
        paymentProviders: result.paymentProviders,
        paymentProvidersLoaded: true,
        message: null,
      ));
      return true;
    } on Object catch (error) {
      return _fail(_checkoutMessageOf(error));
    }
  }

  /// Retains one region-supported provider on the server-owned cart.
  Future<bool> selectPayment(String providerId) async {
    if (state.isBusy) return false;
    emit(state.copyWith(
      status: CheckoutStatus.loading,
      operation: CheckoutOperation.payment,
      message: null,
    ));
    final selected = await args.cart.choosePayment(providerId);
    if (!selected) return _cartFailure();
    emit(state.copyWith(
      status: CheckoutStatus.ready,
      paymentMethod: Some(providerId),
      message: null,
    ));
    return true;
  }

  bool _cartFailure() => _fail(
        args.cart.state.message ?? 'Could not update delivery. Try again.',
      );

  bool _fail(String message) {
    emit(state.copyWith(status: CheckoutStatus.failed, message: message));
    return false;
  }

  void _set(CheckoutState next) => emit(next);
}
