import 'package:admin_app/src/order/admin_return_api.dart';
import 'package:admin_app/src/order/admin_return_state.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dio/dio.dart';
import 'package:dust_dart/fp.dart';
import 'package:dust_flutter/state.dart';

part 'admin_return_view_model.g.dart';

/// Dependencies for requested returns attached to one Admin order.
final class AdminReturnViewModelArgs extends ViewModelArgs {
  /// Creates requested-return dependencies.
  const AdminReturnViewModelArgs({required this.api, super.observer});

  /// Generated return client using Dio-level authorization.
  final AdminReturnApi api;
}

/// Loads the receivable returns used by Medusa's order Summary action.
@ViewModel(state: AdminReturnState, args: AdminReturnViewModelArgs)
final class AdminReturnViewModel extends $AdminReturnViewModel {
  /// Creates the requested-return state machine.
  AdminReturnViewModel(super.args);

  int _revision = 0;

  /// Loads requested returns for one immutable [orderId].
  Future<void> loadRequested(String orderId) async {
    final revision = ++_revision;
    emit(const AdminReturnState(status: AdminReturnLoadStatus.loading));
    try {
      final page = await args.api.list(orderId, 'requested', 100, 0);
      if (revision != _revision) return;
      emit(AdminReturnState(
        status: AdminReturnLoadStatus.ready,
        returns: List.unmodifiable(page.returns),
      ));
    } on DioException catch (error) {
      if (revision != _revision) return;
      _fail(error.response?.statusCode == 401
          ? 'Your admin session has expired.'
          : 'Unable to load returns. Try again.');
    } on Object {
      if (revision != _revision) return;
      _fail('Unable to load returns. Try again.');
    }
  }

  /// Records one atomic [body] and removes its terminal return from the list.
  Future<void> receive(String returnId, AdminReceiveReturn body) async {
    final revision = ++_revision;
    emit(state.copyWith(
      status: AdminReturnLoadStatus.saving,
      failure: const None(),
    ));
    try {
      await args.api.receive(returnId, body);
      if (revision != _revision) return;
      emit(state.copyWith(
        status: AdminReturnLoadStatus.ready,
        returns: List.unmodifiable(
          state.returns.where((value) => value.id != returnId),
        ),
        failure: const None(),
      ));
    } on DioException catch (error) {
      if (revision != _revision) return;
      _fail(switch (error.response?.statusCode) {
        401 => 'Your admin session has expired.',
        422 => 'Return receipt quantities are invalid.',
        _ => 'Unable to receive this return. Try again.',
      });
    } on Object {
      if (revision != _revision) return;
      _fail('Unable to receive this return. Try again.');
    }
  }

  void _fail(String message) => emit(state.copyWith(
        status: AdminReturnLoadStatus.failed,
        failure: Some(message),
      ));
}
