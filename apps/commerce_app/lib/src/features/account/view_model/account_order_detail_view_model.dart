import 'package:commerce_app/src/core/api/api.dart';
import 'package:commerce_app/src/features/account/model/account_order_detail_state.dart';
import 'package:dio/dio.dart';
import 'package:dust_dart/fp.dart';
import 'package:dust_flutter/state.dart';

part 'account_order_detail_view_model.g.dart';

/// Dependencies for one customer-owned order detail.
final class AccountOrderDetailViewModelArgs extends ViewModelArgs {
  /// Creates order-detail dependencies.
  const AccountOrderDetailViewModelArgs({required this.api, super.observer});

  /// Generated store API with Dio-owned authorization.
  final CommerceApi api;
}

/// Loads exactly one order through the authenticated ownership boundary.
@ViewModel(
  state: AccountOrderDetailState,
  args: AccountOrderDetailViewModelArgs,
)
final class AccountOrderDetailViewModel extends $AccountOrderDetailViewModel {
  /// Creates the order-detail state machine.
  AccountOrderDetailViewModel(super.args);

  var _generation = 0;

  /// Clears customer-owned detail when authenticated identity changes.
  void reset() {
    _generation++;
    emit(const AccountOrderDetailState());
  }

  /// Loads [id] only when the server proves current-customer ownership.
  Future<void> load(String id) async {
    final generation = ++_generation;
    emit(const AccountOrderDetailState(
      status: AccountOrderDetailStatus.loading,
    ));
    try {
      final order = await args.api.order(id);
      if (generation != _generation) return;
      emit(AccountOrderDetailState(
        status: AccountOrderDetailStatus.ready,
        order: Some(order),
      ));
    } on Object catch (error) {
      if (generation != _generation) return;
      emit(AccountOrderDetailState(
        status: AccountOrderDetailStatus.failed,
        failure: Some(_orderDetailFailure(error)),
      ));
    }
  }
}

AccountOrderDetailFailure _orderDetailFailure(Object error) {
  if (error is DioException) {
    return switch (error.response?.statusCode) {
      401 => AccountOrderDetailFailure.sessionExpired,
      404 => AccountOrderDetailFailure.unavailable,
      _ => AccountOrderDetailFailure.retryable,
    };
  }
  return AccountOrderDetailFailure.retryable;
}
