import 'package:admin_app/src/core/admin_api.dart';
import 'package:admin_app/src/order/admin_order_export_api.dart';
import 'package:admin_app/src/order/admin_order_region_api.dart';
import 'package:admin_app/src/order/admin_order_sales_channel_api.dart';
import 'package:admin_app/src/order/admin_order_state.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dio/dio.dart';
import 'package:dust_dart/fp.dart';
import 'package:dust_flutter/state.dart';

part 'admin_order_view_model.g.dart';
part 'admin_order_export.dart';
part 'admin_order_filters.dart';

/// Dependencies for the authenticated merchant order table.
final class AdminOrderViewModelArgs extends ViewModelArgs {
  /// Creates order-list dependencies.
  const AdminOrderViewModelArgs({
    required this.api,
    required this.exports,
    required this.regions,
    required this.salesChannels,
    super.observer,
  });

  /// Generated admin-only API client.
  final AdminApi api;

  /// Generated CSV client using the same Dio authorization boundary.
  final AdminOrderExportApi exports;

  /// Generated region client using the same Dio authorization boundary.
  final AdminOrderRegionApi regions;

  /// Generated sales-channel client sharing Dio authorization.
  final AdminOrderSalesChannelApi salesChannels;
}

/// Loads and pages immutable merchant order summaries.
@ViewModel(state: AdminOrderState, args: AdminOrderViewModelArgs)
final class AdminOrderViewModel extends $AdminOrderViewModel {
  /// Creates the order-list state machine.
  AdminOrderViewModel(super.args);

  int _revision = 0;

  /// Loads the real region and sales-channel choices used by Medusa's filters.
  Future<void> loadFilterOptions() async {
    if (state.filterOptionsStatus == AdminOrderFilterOptionsStatus.loading ||
        state.filterOptionsStatus == AdminOrderFilterOptionsStatus.ready) {
      return;
    }
    emit(state.copyWith(
      filterOptionsStatus: AdminOrderFilterOptionsStatus.loading,
      filterOptionsFailure: const None(),
    ));
    try {
      final regions = await args.regions.listRegions('', 1000, 0);
      final salesChannels =
          await args.salesChannels.listSalesChannels('', 1000, 0);
      emit(state.copyWith(
        filterOptionsStatus: AdminOrderFilterOptionsStatus.ready,
        filterOptionsFailure: const None(),
        regions: List.unmodifiable(regions.regions),
        salesChannels: List.unmodifiable(salesChannels.salesChannels),
      ));
    } on DioException catch (error) {
      _filterOptionsFailed(error.response?.statusCode == 401
          ? 'Your admin session has expired.'
          : 'Unable to load filter choices. Try again.');
    } on Object {
      _filterOptionsFailed('Unable to load filter choices. Try again.');
    }
  }

  /// Loads the first page for [query].
  Future<void> search(String query) => load(query: query, offset: 0);

  /// Loads one bounded order page.
  Future<void> load({
    String? query,
    int? offset,
    List<AdminOrderStatus>? statuses,
    List<String>? regionIds,
    List<String>? salesChannelIds,
    AdminDateFilter? createdAt,
    AdminDateFilter? updatedAt,
    AdminOrderOrder? order,
  }) async {
    final nextQuery = (query ?? state.query).trim();
    final nextOffset = (offset ?? state.offset).clamp(0, 1 << 31);
    final nextStatuses = statuses ?? state.statuses;
    final nextRegionIds = regionIds ?? state.regionIds;
    final nextSalesChannelIds = salesChannelIds ?? state.salesChannelIds;
    final nextCreatedAt = createdAt ?? state.createdAt;
    final nextUpdatedAt = updatedAt ?? state.updatedAt;
    final nextOrder = order ?? state.order;
    final revision = ++_revision;
    emit(state.copyWith(
      status: AdminOrderListStatus.loading,
      offset: nextOffset,
      query: nextQuery,
      statuses: nextStatuses,
      regionIds: nextRegionIds,
      salesChannelIds: nextSalesChannelIds,
      createdAt: nextCreatedAt,
      updatedAt: nextUpdatedAt,
      order: nextOrder,
      failure: const None(),
    ));
    try {
      final result = await args.api.listOrders(
        nextQuery,
        nextStatuses.map((status) => status.name).join(','),
        nextRegionIds.join(','),
        nextSalesChannelIds.join(','),
        nextCreatedAt.isEmpty ? '' : nextCreatedAt.parameter,
        nextUpdatedAt.isEmpty ? '' : nextUpdatedAt.parameter,
        nextOrder.parameter,
        state.limit,
        nextOffset,
      );
      if (revision != _revision) return;
      emit(state.copyWith(
        status: AdminOrderListStatus.ready,
        orders: List.unmodifiable(result.orders),
        count: result.count,
        limit: result.limit,
        offset: result.offset,
        failure: const None(),
      ));
    } on DioException catch (error) {
      if (revision != _revision) return;
      _fail(error.response?.statusCode == 401
          ? 'Your admin session has expired.'
          : 'Unable to load orders. Try again.');
    } on Object {
      if (revision != _revision) return;
      _fail('Unable to load orders. Try again.');
    }
  }

  /// Loads the preceding server page.
  Future<void> previous() =>
      load(offset: (state.offset - state.limit).clamp(0, 1 << 31));

  /// Loads the following server page.
  Future<void> next() => load(offset: state.offset + state.limit);

  void _fail(String message) => emit(state.copyWith(
        status: AdminOrderListStatus.failed,
        failure: Some(message),
      ));

  void _filterOptionsFailed(String message) => emit(state.copyWith(
        filterOptionsStatus: AdminOrderFilterOptionsStatus.failed,
        filterOptionsFailure: Some(message),
      ));
}
