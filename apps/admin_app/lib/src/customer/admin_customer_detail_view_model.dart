import 'package:admin_app/src/customer/admin_customer_api.dart';
import 'package:admin_app/src/customer/admin_customer_detail_state.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dio/dio.dart';
import 'package:dust_dart/fp.dart';
import 'package:dust_flutter/state.dart';

part 'admin_customer_detail_view_model.g.dart';

/// Dependencies for one authenticated merchant customer detail.
final class AdminCustomerDetailViewModelArgs extends ViewModelArgs {
  /// Creates customer-detail dependencies.
  const AdminCustomerDetailViewModelArgs({required this.api, super.observer});

  /// Generated customer client using Dio-level authorization.
  final AdminCustomerApi api;
}

/// Loads one customer and its independently pageable order history.
@ViewModel(
  state: AdminCustomerDetailState,
  args: AdminCustomerDetailViewModelArgs,
)
final class AdminCustomerDetailViewModel extends $AdminCustomerDetailViewModel {
  /// Creates the customer-detail state machine.
  AdminCustomerDetailViewModel(super.args);

  int _detailRevision = 0;
  int _orderRevision = 0;

  /// Loads the complete allowlisted customer and first order page.
  Future<void> load(String id) async {
    final revision = ++_detailRevision;
    emit(AdminCustomerDetailState(
      status: AdminCustomerDetailStatus.loading,
      customerId: id,
      ordersStatus: AdminCustomerOrdersStatus.loading,
    ));
    try {
      final customer = await args.api.customer(id);
      if (revision != _detailRevision) return;
      emit(state.copyWith(
        status: AdminCustomerDetailStatus.ready,
        customer: Some(customer),
        failure: const None(),
      ));
      await loadOrders(offset: 0);
    } on DioException catch (error) {
      if (revision != _detailRevision) return;
      _detailFailed(switch (error.response?.statusCode) {
        404 => 'This customer no longer exists.',
        401 => 'Your admin session has expired.',
        _ => 'Unable to load this customer. Try again.',
      });
    } on Object {
      if (revision != _detailRevision) return;
      _detailFailed('Unable to load this customer. Try again.');
    }
  }

  /// Searches this customer's order history from its first page.
  Future<void> searchOrders(String query) =>
      loadOrders(query: query, offset: 0);

  /// Loads one customer-owned order page without replacing profile state.
  Future<void> loadOrders({
    String? query,
    int? offset,
    AdminOrderOrder? order,
  }) async {
    if (state.customerId.isEmpty) return;
    final nextQuery = (query ?? state.orderQuery).trim();
    final nextOffset = (offset ?? state.orderOffset).clamp(0, 1 << 31);
    final nextOrder = order ?? state.order;
    final revision = ++_orderRevision;
    emit(state.copyWith(
      ordersStatus: AdminCustomerOrdersStatus.loading,
      orderQuery: nextQuery,
      orderOffset: nextOffset,
      order: nextOrder,
      orderFailure: const None(),
    ));
    try {
      final result = await args.api.listCustomerOrders(
        state.customerId,
        nextQuery,
        nextOrder.parameter,
        state.orderLimit,
        nextOffset,
      );
      if (revision != _orderRevision) return;
      emit(state.copyWith(
        ordersStatus: AdminCustomerOrdersStatus.ready,
        orders: List.unmodifiable(result.orders),
        orderCount: result.count,
        orderLimit: result.limit,
        orderOffset: result.offset,
      ));
    } on DioException catch (error) {
      if (revision != _orderRevision) return;
      _ordersFailed(error.response?.statusCode == 401
          ? 'Your admin session has expired.'
          : 'Unable to load customer orders. Try again.');
    } on Object {
      if (revision != _orderRevision) return;
      _ordersFailed('Unable to load customer orders. Try again.');
    }
  }

  /// Loads the preceding customer-order page.
  Future<void> previousOrders() => loadOrders(
        offset: (state.orderOffset - state.orderLimit).clamp(0, 1 << 31),
      );

  /// Loads the following customer-order page.
  Future<void> nextOrders() =>
      loadOrders(offset: state.orderOffset + state.orderLimit);

  void _detailFailed(String message) => emit(state.copyWith(
        status: AdminCustomerDetailStatus.failed,
        customer: const None(),
        ordersStatus: AdminCustomerOrdersStatus.idle,
        failure: Some(message),
      ));

  void _ordersFailed(String message) => emit(state.copyWith(
        ordersStatus: AdminCustomerOrdersStatus.failed,
        orderFailure: Some(message),
      ));
}
