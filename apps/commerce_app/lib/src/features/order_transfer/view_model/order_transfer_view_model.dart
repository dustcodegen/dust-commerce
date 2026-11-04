import 'package:commerce_app/src/core/api/api.dart';
import 'package:commerce_app/src/features/order_transfer/model/model.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dio/dio.dart';
import 'package:dust_dart/fp.dart';
import 'package:dust_flutter/state.dart';

part 'order_transfer_view_model.g.dart';

/// Dependencies for the public and authenticated transfer screens.
final class OrderTransferViewModelArgs extends ViewModelArgs {
  /// Creates transfer dependencies.
  const OrderTransferViewModelArgs({required this.api, super.observer});

  /// Generated API with authorization attached only by Dio.
  final CommerceApi api;
}

/// Runs one order-transfer action without retaining its capability in state.
@ViewModel(state: OrderTransferState, args: OrderTransferViewModelArgs)
final class OrderTransferViewModel extends $OrderTransferViewModel {
  /// Creates the transfer state machine.
  OrderTransferViewModel(super.args);

  var _generation = 0;

  /// Clears screen state and ignores a previous in-flight result.
  void reset() {
    _generation++;
    emit(const OrderTransferState());
  }

  /// Requests transfer to the currently authenticated customer.
  Future<void> request(String orderId) => _run(
        OrderTransferAction.request,
        orderId,
        (id) => args.api.requestOrderTransfer(id),
      );

  /// Accepts the transfer using the capability held only by this call.
  Future<void> accept(String orderId, String token) => _run(
        OrderTransferAction.accept,
        orderId,
        (id) => args.api.acceptOrderTransfer(
          id,
          OrderTransferDecisionBody(token: token),
        ),
      );

  /// Declines the transfer using the capability held only by this call.
  Future<void> decline(String orderId, String token) => _run(
        OrderTransferAction.decline,
        orderId,
        (id) => args.api.declineOrderTransfer(
          id,
          OrderTransferDecisionBody(token: token),
        ),
      );

  Future<void> _run(
    OrderTransferAction action,
    String orderId,
    Future<OrderTransferView> Function(String id) operation,
  ) async {
    if (state.status == OrderTransferActionStatus.pending) return;
    final id = orderId.trim();
    if (id.isEmpty) {
      emit(OrderTransferState(
        status: OrderTransferActionStatus.failed,
        action: Some(action),
        failure: const Some(OrderTransferFailure.invalidRequest),
      ));
      return;
    }

    final generation = ++_generation;
    emit(OrderTransferState(
      status: OrderTransferActionStatus.pending,
      action: Some(action),
      orderId: Some(id),
    ));
    try {
      final result = await operation(id);
      if (generation != _generation) return;
      if (result.orderId != id) throw StateError('Unexpected transfer order');
      emit(OrderTransferState(
        status: OrderTransferActionStatus.succeeded,
        action: Some(action),
        orderId: Some(id),
        deliveryStatus: action == OrderTransferAction.request
            ? Some(result.deliveryStatus)
            : const None(),
      ));
    } on Object catch (error) {
      if (generation != _generation) return;
      emit(OrderTransferState(
        status: OrderTransferActionStatus.failed,
        action: Some(action),
        orderId: Some(id),
        failure: Some(_classifyTransferFailure(error, action)),
      ));
    }
  }
}

OrderTransferFailure _classifyTransferFailure(
  Object error,
  OrderTransferAction action,
) {
  if (error is DioException) {
    return switch (error.response?.statusCode) {
      401 => OrderTransferFailure.unauthorized,
      404 => OrderTransferFailure.unavailable,
      409 => OrderTransferFailure.conflict,
      422 when action == OrderTransferAction.request =>
        OrderTransferFailure.invalidRequest,
      422 => OrderTransferFailure.orderUnavailable,
      503 => OrderTransferFailure.deliveryUnavailable,
      _ => OrderTransferFailure.retryable,
    };
  }
  return OrderTransferFailure.retryable;
}
