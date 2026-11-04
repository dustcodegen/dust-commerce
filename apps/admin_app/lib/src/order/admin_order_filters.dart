part of 'admin_order_view_model.dart';

/// Filter and ordering commands separated from request lifecycle.
extension AdminOrderFilters on AdminOrderViewModel {
  /// Applies an inclusive creation-time range and resets paging.
  Future<void> filterByCreatedAt({
    required Option<DateTime> from,
    required Option<DateTime> to,
  }) =>
      load(
        createdAt: AdminDateFilter(
          greaterThanOrEqual: from,
          lessThanOrEqual: to,
        ),
        offset: 0,
      );

  /// Applies selected selling-region identifiers and resets paging.
  Future<void> filterByRegions(List<String> regionIds) => load(
        regionIds: List.unmodifiable(regionIds.toSet()),
        offset: 0,
      );

  /// Applies selected commercial-origin identifiers and resets paging.
  Future<void> filterBySalesChannels(List<String> salesChannelIds) => load(
        salesChannelIds: List.unmodifiable(salesChannelIds.toSet()),
        offset: 0,
      );

  /// Applies selected lifecycle states and resets paging.
  Future<void> filterByStatuses(List<AdminOrderStatus> statuses) => load(
        statuses: List.unmodifiable(statuses.toSet()),
        offset: 0,
      );

  /// Applies an inclusive update-time range and resets paging.
  Future<void> filterByUpdatedAt({
    required Option<DateTime> from,
    required Option<DateTime> to,
  }) =>
      load(
        updatedAt: AdminDateFilter(
          greaterThanOrEqual: from,
          lessThanOrEqual: to,
        ),
        offset: 0,
      );

  /// Applies one allowlisted server ordering and resets paging.
  Future<void> orderBy(AdminOrderOrder order) => load(order: order, offset: 0);

  /// Removes filters while preserving search and ordering.
  Future<void> clearFilters() => load(
        statuses: const [],
        regionIds: const [],
        salesChannelIds: const [],
        createdAt: const AdminDateFilter(),
        updatedAt: const AdminDateFilter(),
        offset: 0,
      );
}
