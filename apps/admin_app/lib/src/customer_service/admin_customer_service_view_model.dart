import 'package:admin_app/src/customer_service/admin_customer_service_api.dart';
import 'package:admin_app/src/customer_service/admin_customer_service_state.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dio/dio.dart';
import 'package:dust_dart/fp.dart';
import 'package:dust_flutter/state.dart';

part 'admin_customer_service_view_model.g.dart';

/// Dependencies for the authenticated merchant support inbox.
final class AdminCustomerServiceViewModelArgs extends ViewModelArgs {
  /// Creates support-inbox dependencies.
  const AdminCustomerServiceViewModelArgs({required this.api, super.observer});

  /// Generated Admin-only support client.
  final AdminCustomerServiceApi api;
}

/// Loads, filters, pages, and triages customer-service requests.
@ViewModel(
  state: AdminCustomerServiceState,
  args: AdminCustomerServiceViewModelArgs,
)
final class AdminCustomerServiceViewModel
    extends $AdminCustomerServiceViewModel {
  /// Creates the support-inbox state machine.
  AdminCustomerServiceViewModel(super.args);

  var _revision = 0;

  /// Loads the first page for [query].
  Future<void> search(String query) => load(query: query, offset: 0);

  /// Loads one bounded inbox page.
  Future<void> load({
    String? query,
    int? offset,
    List<AdminCustomerServiceStatus>? statuses,
    AdminCustomerServiceOrder? order,
  }) async {
    final nextQuery = (query ?? state.query).trim();
    final nextOffset = (offset ?? state.offset).clamp(0, 1 << 31);
    final nextStatuses = statuses ?? state.statuses;
    final nextOrder = order ?? state.order;
    final revision = ++_revision;
    emit(state.copyWith(
      status: AdminCustomerServiceListStatus.loading,
      query: nextQuery,
      offset: nextOffset,
      statuses: nextStatuses,
      order: nextOrder,
      updatingId: const None(),
      failure: const None(),
    ));
    try {
      const codec = AdminCustomerServiceStatusCodec();
      final result = await args.api.list(
        nextQuery,
        nextStatuses.map(codec.serialize).join(','),
        nextOrder.parameter,
        state.limit,
        nextOffset,
      );
      if (revision != _revision) return;
      emit(state.copyWith(
        status: AdminCustomerServiceListStatus.ready,
        requests: List.unmodifiable(result.requests),
        count: result.count,
        limit: result.limit,
        offset: result.offset,
        failure: const None(),
      ));
    } on DioException catch (error) {
      if (revision != _revision) return;
      _fail(error.response?.statusCode == 401
          ? 'Your admin session has expired.'
          : 'Unable to load customer-service requests. Try again.');
    } on Object {
      if (revision != _revision) return;
      _fail('Unable to load customer-service requests. Try again.');
    }
  }

  /// Applies the selected lifecycle filters from the first page.
  Future<void> filter(List<AdminCustomerServiceStatus> statuses) =>
      load(statuses: List.unmodifiable(statuses), offset: 0);

  /// Applies one allowlisted inbox ordering from the first page.
  Future<void> sort(AdminCustomerServiceOrder order) =>
      load(order: order, offset: 0);

  /// Clears lifecycle filters from the first page.
  Future<void> clearFilters() => load(statuses: const [], offset: 0);

  /// Loads the preceding server page.
  Future<void> previous() =>
      load(offset: (state.offset - state.limit).clamp(0, 1 << 31));

  /// Loads the following server page.
  Future<void> next() => load(offset: state.offset + state.limit);

  /// Replaces one request lifecycle without nesting result boundaries.
  Future<bool> updateStatus(
    String id,
    AdminCustomerServiceStatus status,
  ) async {
    if (state.updatingId case Some()) return false;
    final revision = ++_revision;
    emit(state.copyWith(updatingId: Some(id), failure: const None()));
    try {
      final updated = await args.api.update(
        id,
        AdminUpdateCustomerService(status: status),
      );
      if (revision != _revision) return false;
      final visible = state.statuses.isEmpty || state.statuses.contains(status);
      final requests = visible
          ? state.requests
              .map((request) => request.id == id ? updated : request)
              .toList(growable: false)
          : state.requests.where((request) => request.id != id).toList();
      emit(state.copyWith(
        requests: List.unmodifiable(requests),
        count: visible ? state.count : (state.count - 1).clamp(0, 1 << 31),
        updatingId: const None(),
        failure: const None(),
      ));
      return true;
    } on DioException catch (error) {
      if (revision != _revision) return false;
      _updateFailed(error.response?.statusCode == 401
          ? 'Your admin session has expired.'
          : 'Unable to update this request. Try again.');
    } on Object {
      if (revision != _revision) return false;
      _updateFailed('Unable to update this request. Try again.');
    }
    return false;
  }

  void _fail(String message) => emit(state.copyWith(
        status: AdminCustomerServiceListStatus.failed,
        failure: Some(message),
      ));

  void _updateFailed(String message) => emit(state.copyWith(
        updatingId: const None(),
        failure: Some(message),
      ));
}
