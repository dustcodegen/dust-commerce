part of 'admin_product_view_model.dart';

/// Filter and ordering commands kept separate from product request lifecycle.
extension AdminProductFilters on AdminProductViewModel {
  /// Applies an inclusive creation-time range and resets server paging.
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

  /// Applies the selected lifecycle states and resets server paging.
  Future<void> filterByStatuses(List<AdminProductLifecycle> statuses) => load(
        statuses: List.unmodifiable(statuses.toSet()),
        offset: 0,
      );

  /// Applies selected public tag ids and resets server paging.
  Future<void> filterByTags(List<String> tagIds) => load(
        tagIds: List.unmodifiable(tagIds.toSet()),
        offset: 0,
      );

  /// Applies selected normalized product-type ids and resets paging.
  Future<void> filterByTypes(List<String> typeIds) => load(
        typeIds: List.unmodifiable(typeIds.toSet()),
        offset: 0,
      );

  /// Applies an inclusive update-time range and resets server paging.
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
  Future<void> orderBy(AdminProductOrder order) => load(
        order: order,
        offset: 0,
      );

  /// Removes every active filter while preserving search and ordering.
  Future<void> clearFilters() => load(
        statuses: const [],
        tagIds: const [],
        typeIds: const [],
        createdAt: const AdminDateFilter(),
        updatedAt: const AdminDateFilter(),
        offset: 0,
      );
}
