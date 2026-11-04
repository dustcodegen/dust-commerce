import 'dart:async';

import 'package:commerce_app/src/core/api/api.dart';
import 'package:commerce_app/src/features/order_return/model/model.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dio/dio.dart';
import 'package:dust_dart/fp.dart';
import 'package:dust_flutter/state.dart';

part 'order_return_history_view_model.g.dart';

const _historyPageSize = 10;

/// Dependencies for customer return-history paging.
final class OrderReturnHistoryViewModelArgs extends ViewModelArgs {
  /// Creates return-history dependencies.
  const OrderReturnHistoryViewModelArgs({required this.api, super.observer});

  /// Focused generated API using the shared Dio bearer interceptor.
  final OrderReturnHistoryApi api;
}

/// Owns authenticated return-history loading independently from request forms.
@ViewModel(
  state: OrderReturnHistoryState,
  args: OrderReturnHistoryViewModelArgs,
)
final class OrderReturnHistoryViewModel extends $OrderReturnHistoryViewModel {
  /// Creates the paginated history state machine.
  OrderReturnHistoryViewModel(super.args);

  var _generation = 0;

  /// Clears customer-owned history when authenticated identity changes.
  void reset() {
    _generation++;
    emit(const OrderReturnHistoryState());
  }

  /// Loads the newest page for one proven customer order.
  Future<void> load(String orderId) => _fetch(orderId, append: false);

  /// Loads the next page while retaining current rows.
  Future<void> loadMore() async {
    if (!state.hasMore ||
        state.status == OrderReturnHistoryStatus.loading ||
        state.status == OrderReturnHistoryStatus.loadingMore) {
      return;
    }
    final orderId = state.orderId.unwrapOr('');
    if (orderId.isNotEmpty) await _fetch(orderId, append: true);
  }

  /// Reloads the first page after a retry action.
  Future<void> retry() async {
    final orderId = state.orderId.unwrapOr('');
    if (orderId.isNotEmpty) await load(orderId);
  }

  /// Refreshes history after the server acknowledges a new owned request.
  void record(OrderReturnView response) {
    if (state.orderId == Some(response.orderId)) {
      unawaited(load(response.orderId));
    }
  }

  Future<void> _fetch(String orderId, {required bool append}) async {
    final generation = ++_generation;
    final offset = append ? state.offset : 0;
    emit(append
        ? state.copyWith(
            status: OrderReturnHistoryStatus.loadingMore,
            failure: const None(),
          )
        : OrderReturnHistoryState(
            status: OrderReturnHistoryStatus.loading,
            orderId: Some(orderId),
          ));
    try {
      final page = await args.api.returns(
        orderId,
        limit: _historyPageSize,
        offset: offset,
      );
      if (generation != _generation) return;
      if (page.offset != offset ||
          page.returns.any((item) => item.orderId != orderId)) {
        throw StateError('Unexpected return history page');
      }
      final existing = append ? state.returns : const <OrderReturnView>[];
      final byId = {for (final item in existing) item.id: item};
      for (final item in page.returns) {
        byId[item.id] = item;
      }
      emit(OrderReturnHistoryState(
        status: OrderReturnHistoryStatus.ready,
        orderId: Some(orderId),
        returns: byId.values.toList(growable: false),
        count: page.count,
        offset: page.offset + page.returns.length,
      ));
    } on Object catch (error) {
      if (generation != _generation) return;
      emit(state.copyWith(
        status: OrderReturnHistoryStatus.failed,
        failure: Some(_historyFailure(error)),
      ));
    }
  }
}

OrderReturnHistoryFailure _historyFailure(Object error) {
  if (error is DioException) {
    return switch (error.response?.statusCode) {
      401 => OrderReturnHistoryFailure.sessionExpired,
      404 => OrderReturnHistoryFailure.unavailable,
      _ => OrderReturnHistoryFailure.retryable,
    };
  }
  return OrderReturnHistoryFailure.retryable;
}
