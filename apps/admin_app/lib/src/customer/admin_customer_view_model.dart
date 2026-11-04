import 'package:admin_app/src/customer/admin_customer_api.dart';
import 'package:admin_app/src/customer/admin_customer_state.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dio/dio.dart';
import 'package:dust_dart/fp.dart';
import 'package:dust_flutter/state.dart';

part 'admin_customer_view_model.g.dart';
part 'admin_customer_filters.dart';

/// Dependencies for the authenticated merchant customer table.
final class AdminCustomerViewModelArgs extends ViewModelArgs {
  /// Creates customer-list dependencies.
  const AdminCustomerViewModelArgs({required this.api, super.observer});

  /// Generated Admin-only customer client.
  final AdminCustomerApi api;
}

/// Loads and pages immutable merchant customer summaries.
@ViewModel(state: AdminCustomerState, args: AdminCustomerViewModelArgs)
final class AdminCustomerViewModel extends $AdminCustomerViewModel {
  /// Creates the customer-list state machine.
  AdminCustomerViewModel(super.args);

  int _revision = 0;

  /// Loads the first page for [query].
  Future<void> search(String query) => load(query: query, offset: 0);

  /// Loads one bounded customer page.
  Future<void> load({
    String? query,
    int? offset,
    Option<bool>? hasAccount,
    AdminDateFilter? createdAt,
    AdminDateFilter? updatedAt,
    AdminCustomerOrder? order,
  }) async {
    final nextQuery = (query ?? state.query).trim();
    final nextOffset = (offset ?? state.offset).clamp(0, 1 << 31);
    final nextAccount = hasAccount ?? state.hasAccount;
    final nextCreatedAt = createdAt ?? state.createdAt;
    final nextUpdatedAt = updatedAt ?? state.updatedAt;
    final nextOrder = order ?? state.order;
    final revision = ++_revision;
    emit(state.copyWith(
      status: AdminCustomerListStatus.loading,
      offset: nextOffset,
      query: nextQuery,
      hasAccount: nextAccount,
      createdAt: nextCreatedAt,
      updatedAt: nextUpdatedAt,
      order: nextOrder,
      failure: const None(),
    ));
    try {
      final result = await args.api.listCustomers(
        nextQuery,
        switch (nextAccount) {
          Some(:final value) => value.toString(),
          None() => '',
        },
        nextCreatedAt.isEmpty ? '' : nextCreatedAt.parameter,
        nextUpdatedAt.isEmpty ? '' : nextUpdatedAt.parameter,
        nextOrder.parameter,
        state.limit,
        nextOffset,
      );
      if (revision != _revision) return;
      emit(state.copyWith(
        status: AdminCustomerListStatus.ready,
        customers: List.unmodifiable(result.customers),
        count: result.count,
        limit: result.limit,
        offset: result.offset,
        failure: const None(),
      ));
    } on DioException catch (error) {
      if (revision != _revision) return;
      _fail(error.response?.statusCode == 401
          ? 'Your admin session has expired.'
          : 'Unable to load customers. Try again.');
    } on Object {
      if (revision != _revision) return;
      _fail('Unable to load customers. Try again.');
    }
  }

  /// Loads the preceding server page.
  Future<void> previous() =>
      load(offset: (state.offset - state.limit).clamp(0, 1 << 31));

  /// Loads the following server page.
  Future<void> next() => load(offset: state.offset + state.limit);

  void _fail(String message) => emit(state.copyWith(
        status: AdminCustomerListStatus.failed,
        failure: Some(message),
      ));
}
