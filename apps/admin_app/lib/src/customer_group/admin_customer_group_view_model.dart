import 'package:admin_app/src/customer_group/admin_customer_group_api.dart';
import 'package:admin_app/src/customer_group/admin_customer_group_state.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dio/dio.dart';
import 'package:dust_dart/fp.dart';
import 'package:dust_flutter/state.dart';

part 'admin_customer_group_view_model.g.dart';
part 'admin_customer_group_filters.dart';

/// Dependencies for the authenticated merchant customer-group table.
final class AdminCustomerGroupViewModelArgs extends ViewModelArgs {
  /// Creates customer-group list dependencies.
  const AdminCustomerGroupViewModelArgs({required this.api, super.observer});

  /// Generated Admin-only customer-group client.
  final AdminCustomerGroupApi api;
}

/// Loads and pages immutable merchant customer-group summaries.
@ViewModel(
  state: AdminCustomerGroupState,
  args: AdminCustomerGroupViewModelArgs,
)
final class AdminCustomerGroupViewModel extends $AdminCustomerGroupViewModel {
  /// Creates the customer-group list state machine.
  AdminCustomerGroupViewModel(super.args);

  int _revision = 0;

  /// Loads the first page for [query].
  Future<void> search(String query) => load(query: query, offset: 0);

  /// Loads one bounded customer-group page.
  Future<void> load({
    String? query,
    int? offset,
    AdminDateFilter? createdAt,
    AdminDateFilter? updatedAt,
    AdminCustomerGroupOrder? order,
  }) async {
    final nextQuery = (query ?? state.query).trim();
    final nextOffset = (offset ?? state.offset).clamp(0, 1 << 31);
    final nextCreatedAt = createdAt ?? state.createdAt;
    final nextUpdatedAt = updatedAt ?? state.updatedAt;
    final nextOrder = order ?? state.order;
    final revision = ++_revision;
    emit(state.copyWith(
      status: AdminCustomerGroupStatus.loading,
      offset: nextOffset,
      query: nextQuery,
      createdAt: nextCreatedAt,
      updatedAt: nextUpdatedAt,
      order: nextOrder,
      failure: const None(),
    ));
    try {
      final result = await args.api.listCustomerGroups(
        nextQuery,
        nextCreatedAt.isEmpty ? '' : nextCreatedAt.parameter,
        nextUpdatedAt.isEmpty ? '' : nextUpdatedAt.parameter,
        nextOrder.parameter,
        state.limit,
        nextOffset,
      );
      if (revision != _revision) return;
      emit(state.copyWith(
        status: AdminCustomerGroupStatus.ready,
        customerGroups: List.unmodifiable(result.customerGroups),
        count: result.count,
        limit: result.limit,
        offset: result.offset,
        failure: const None(),
      ));
    } on DioException catch (error) {
      if (revision != _revision) return;
      _fail(error.response?.statusCode == 401
          ? 'Your admin session has expired.'
          : 'Unable to load customer groups. Try again.');
    } on Object {
      if (revision != _revision) return;
      _fail('Unable to load customer groups. Try again.');
    }
  }

  /// Loads the preceding server page.
  Future<void> previous() =>
      load(offset: (state.offset - state.limit).clamp(0, 1 << 31));

  /// Loads the following server page.
  Future<void> next() => load(offset: state.offset + state.limit);

  void _fail(String message) => emit(state.copyWith(
        status: AdminCustomerGroupStatus.failed,
        failure: Some(message),
      ));
}
