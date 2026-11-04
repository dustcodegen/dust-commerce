import 'package:commerce_app/src/core/api/api.dart';
import 'package:commerce_app/src/features/account/model/account_orders_state.dart';
import 'package:dio/dio.dart';
import 'package:dust_dart/fp.dart';
import 'package:dust_flutter/state.dart';

part 'account_orders_view_model.g.dart';

/// Dependencies for customer order history.
final class AccountOrdersViewModelArgs extends ViewModelArgs {
  /// Creates order-history dependencies.
  const AccountOrdersViewModelArgs({required this.api, super.observer});

  /// Generated storefront client with Dio-level authorization.
  final CommerceApi api;
}

/// Loads authenticated customer orders without exposing bearer credentials.
@ViewModel(state: AccountOrdersState, args: AccountOrdersViewModelArgs)
class AccountOrdersViewModel extends $AccountOrdersViewModel {
  /// Creates the order-history view model.
  AccountOrdersViewModel(super.args);

  var _generation = 0;

  /// Clears customer-owned data when the authenticated identity changes.
  void reset() {
    _generation++;
    emit(const AccountOrdersState());
  }

  /// Loads all orders owned by the current authenticated customer.
  Future<void> load() async {
    if (state.status == AccountOrdersStatus.loading) return;
    final generation = _generation;
    emit(AccountOrdersState(
      status: AccountOrdersStatus.loading,
      orders: state.orders,
      hasLoaded: state.hasLoaded,
      failure: const None(),
    ));
    try {
      final view = await args.api.orders();
      if (generation != _generation) return;
      emit(AccountOrdersState(
        status: AccountOrdersStatus.ready,
        orders: view.orders,
        hasLoaded: true,
      ));
    } on DioException catch (error) {
      if (generation != _generation) return;
      final failure = error.response?.statusCode == 401
          ? AccountOrdersFailure.unauthorized
          : AccountOrdersFailure.unavailable;
      emit(AccountOrdersState(
        status: AccountOrdersStatus.failed,
        orders: state.orders,
        hasLoaded: state.hasLoaded,
        failure: Some(failure),
      ));
    } on Object {
      if (generation != _generation) return;
      emit(AccountOrdersState(
        status: AccountOrdersStatus.failed,
        orders: state.orders,
        hasLoaded: state.hasLoaded,
        failure: const Some(AccountOrdersFailure.unavailable),
      ));
    }
  }
}
