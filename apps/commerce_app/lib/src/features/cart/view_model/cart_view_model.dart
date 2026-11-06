import 'package:commerce_app/src/core/api/api.dart';
import 'package:commerce_app/src/core/storage/storage.dart';
import 'package:commerce_app/src/features/cart/model/cart_state.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dio/dio.dart' show DioException;
import 'package:dust_dart/fp.dart';
import 'package:dust_flutter/state.dart';

part 'cart_view_model.g.dart';
part 'cart_mutations.dart';
part 'cart_buy.dart';
part 'cart_restore.dart';
part 'cart_transfer.dart';

/// Dependencies for the storefront cart.
final class CartViewModelArgs extends ViewModelArgs {
  /// Creates cart dependencies.
  const CartViewModelArgs({
    required this.api,
    required this.cartIds,
    required this.selectedRegion,
    this.storageScope = 'guest',
    super.observer,
  });

  /// The generated storefront client.
  final CommerceApi api;

  /// Secure persistence for the opaque cart capability.
  final CartIdStore cartIds;

  /// Current shell region used for restores and new cart creation.
  final Option<Region> Function() selectedRegion;

  /// Separates guest and authenticated customer carts.
  final String storageScope;
}

/// Owns the real server cart used across storefront routes.
@ViewModel(state: CartState, args: CartViewModelArgs)
class CartViewModel extends $CartViewModel {
  /// Creates the cart view model.
  CartViewModel(super.args);

  Future<void>? _restoreTask;
  Future<bool>? _transferTask;
  int _identityRevision = 0;

  @override
  Future<void> onInit() => restore();

  /// Adds one selected variant, creating and persisting a cart when needed.
  Future<bool> add(ProductVariant variant) async {
    if (!_begin(CartOperation.add)) return false;
    var current = state.cart;
    try {
      final added = await args.api.addFormLine(
        variantId: variant.id,
        cartId: current?.cart.id,
        regionId: current == null
            ? args.selectedRegion().match(
                  some: (region) => region.id,
                  none: () => null,
                )
            : null,
      );
      if (current == null) {
        await args.cartIds.write(args.storageScope, added.cart.id);
      }
      return _succeed(added);
    } on Object catch (error) {
      _fail(CartOperation.add, error, cart: current);
      return false;
    }
  }

  bool _begin(CartOperation operation, {String? lineId}) {
    if (state.status == CartStatus.loading) return false;
    emit(state.copyWith(
      status: CartStatus.loading,
      operation: operation,
      activeLineId: lineId,
      message: null,
      transferFailure: operation == CartOperation.transfer
          ? const None<CartTransferFailure>()
          : state.transferFailure,
    ));
    return true;
  }

  Future<bool> _succeed(
    CartView cart, {
    bool resetShippingOptions = false,
  }) async {
    final sameCart = state.cart?.cart.id == cart.cart.id;
    emit(CartState(
      status: CartStatus.ready,
      cart: cart,
      shippingOptions:
          sameCart && !resetShippingOptions ? state.shippingOptions : const [],
      transferFailure: const None(),
      dismissedFreeShippingCartId: state.dismissedFreeShippingCartId,
    ));
    if (!sameCart || resetShippingOptions || state.shippingOptions.isEmpty) {
      await _loadShippingOptionsFor(cart);
    }
    return true;
  }

  void _setState(CartState next) => emit(next);

  Future<void> _loadShippingOptionsFor(CartView cart) async {
    try {
      final view = await args.api.shippingOptions(cart.cart.id);
      final current = state.cart;
      if (current?.cart.id == cart.cart.id) {
        _setShippingOptions(current!, view.shippingOptions);
      }
    } on Object {
      // Optional shell pricing must not replace usable cart content.
    }
  }

  void _setShippingOptions(
    CartView cart,
    List<ShippingOption> options,
  ) {
    emit(CartState(
      status: CartStatus.ready,
      cart: cart,
      shippingOptions: options,
      transferFailure: state.transferFailure,
      dismissedFreeShippingCartId: state.dismissedFreeShippingCartId,
    ));
  }

  /// Keeps a closed free-shipping popup closed while this cart stays active.
  void dismissFreeShippingNudge() {
    final cartId = state.cart?.cart.id;
    if (cartId == null) return;
    emit(state.copyWith(dismissedFreeShippingCartId: Some(cartId)));
  }

  void _clearForIdentity() {
    emit(const CartState(status: CartStatus.ready));
  }

  void _fail(
    CartOperation operation,
    Object error, {
    CartView? cart,
    String? lineId,
  }) {
    emit(CartState(
      status: CartStatus.failed,
      cart: cart ?? state.cart,
      operation: operation,
      activeLineId: lineId,
      shippingOptions: state.shippingOptions,
      message: _messageOf(error),
      transferFailure: operation == CartOperation.transfer
          ? Some(_transferFailureOf(error))
          : state.transferFailure,
      dismissedFreeShippingCartId: state.dismissedFreeShippingCartId,
    ));
  }

  static CartTransferFailure _transferFailureOf(Object error) =>
      error is DioException && error.response?.statusCode == 401
          ? CartTransferFailure.unauthorized
          : CartTransferFailure.unavailable;

  static String _messageOf(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map<String, dynamic> && data['error'] is String) {
        return data['error']! as String;
      }
    }
    return 'Could not update the cart. Please try again.';
  }
}
