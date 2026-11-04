import 'package:admin_app/src/customer_group/admin_customer_group_api.dart';
import 'package:admin_app/src/customer_group/admin_customer_group_detail_state.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dio/dio.dart';
import 'package:dust_dart/fp.dart';
import 'package:dust_flutter/state.dart';

part 'admin_customer_group_detail_view_model.g.dart';

/// Dependencies for one authenticated customer-group detail.
final class AdminCustomerGroupDetailViewModelArgs extends ViewModelArgs {
  /// Creates customer-group detail dependencies.
  const AdminCustomerGroupDetailViewModelArgs({
    required this.api,
    super.observer,
  });

  /// Generated group client using Dio-level authorization.
  final AdminCustomerGroupApi api;
}

/// Loads one group and its independently pageable customer section.
@ViewModel(
  state: AdminCustomerGroupDetailState,
  args: AdminCustomerGroupDetailViewModelArgs,
)
final class AdminCustomerGroupDetailViewModel
    extends $AdminCustomerGroupDetailViewModel {
  /// Creates the customer-group detail state machine.
  AdminCustomerGroupDetailViewModel(super.args);

  int _detailRevision = 0;
  int _customerRevision = 0;

  /// Loads the complete allowlisted group and first customer page.
  Future<void> load(String id) async {
    final revision = ++_detailRevision;
    ++_customerRevision;
    emit(AdminCustomerGroupDetailState(
      status: AdminCustomerGroupDetailStatus.loading,
      customerGroupId: id,
      customersStatus: AdminCustomerGroupCustomersStatus.loading,
    ));
    try {
      final response = await args.api.customerGroup(id);
      if (revision != _detailRevision) return;
      emit(state.copyWith(
        status: AdminCustomerGroupDetailStatus.ready,
        customerGroup: Some(response.customerGroup),
        failure: const None(),
      ));
      await loadCustomers(offset: 0);
    } on DioException catch (error) {
      if (revision != _detailRevision) return;
      _detailFailed(switch (error.response?.statusCode) {
        404 => 'This customer group no longer exists.',
        401 => 'Your admin session has expired.',
        _ => 'Unable to load this customer group. Try again.',
      });
    } on Object {
      if (revision != _detailRevision) return;
      _detailFailed('Unable to load this customer group. Try again.');
    }
  }

  /// Searches this group's customers from its first page.
  Future<void> searchCustomers(String query) =>
      loadCustomers(query: query, offset: 0);

  /// Loads one group-scoped customer page without replacing detail state.
  Future<void> loadCustomers({
    String? query,
    int? offset,
    Option<bool>? hasAccount,
    AdminDateFilter? createdAt,
    AdminDateFilter? updatedAt,
    AdminCustomerOrder? order,
  }) async {
    if (state.customerGroupId.isEmpty) return;
    final nextQuery = (query ?? state.customerQuery).trim();
    final nextOffset = (offset ?? state.customerOffset).clamp(0, 1 << 31);
    final nextAccount = hasAccount ?? state.hasAccount;
    final nextCreatedAt = createdAt ?? state.createdAt;
    final nextUpdatedAt = updatedAt ?? state.updatedAt;
    final nextOrder = order ?? state.order;
    final revision = ++_customerRevision;
    emit(state.copyWith(
      customersStatus: AdminCustomerGroupCustomersStatus.loading,
      customerQuery: nextQuery,
      customerOffset: nextOffset,
      hasAccount: nextAccount,
      createdAt: nextCreatedAt,
      updatedAt: nextUpdatedAt,
      order: nextOrder,
      customerFailure: const None(),
    ));
    try {
      final result = await args.api.listCustomerGroupCustomers(
        state.customerGroupId,
        nextQuery,
        switch (nextAccount) {
          Some(:final value) => value.toString(),
          None() => '',
        },
        nextCreatedAt.isEmpty ? '' : nextCreatedAt.parameter,
        nextUpdatedAt.isEmpty ? '' : nextUpdatedAt.parameter,
        nextOrder.parameter,
        state.customerLimit,
        nextOffset,
      );
      if (revision != _customerRevision) return;
      emit(state.copyWith(
        customersStatus: AdminCustomerGroupCustomersStatus.ready,
        customers: List.unmodifiable(result.customers),
        customerCount: result.count,
        customerLimit: result.limit,
        customerOffset: result.offset,
      ));
    } on DioException catch (error) {
      if (revision != _customerRevision) return;
      _customersFailed(error.response?.statusCode == 401
          ? 'Your admin session has expired.'
          : 'Unable to load group customers. Try again.');
    } on Object {
      if (revision != _customerRevision) return;
      _customersFailed('Unable to load group customers. Try again.');
    }
  }

  /// Loads the preceding customer page.
  Future<void> previousCustomers() => loadCustomers(
        offset: (state.customerOffset - state.customerLimit).clamp(0, 1 << 31),
      );

  /// Loads the following customer page.
  Future<void> nextCustomers() =>
      loadCustomers(offset: state.customerOffset + state.customerLimit);

  void _detailFailed(String message) => emit(state.copyWith(
        status: AdminCustomerGroupDetailStatus.failed,
        customerGroup: const None(),
        customersStatus: AdminCustomerGroupCustomersStatus.idle,
        failure: Some(message),
      ));

  void _customersFailed(String message) => emit(state.copyWith(
        customersStatus: AdminCustomerGroupCustomersStatus.failed,
        customerFailure: Some(message),
      ));
}
