part of 'admin_shipping_profile_view_model.dart';

/// Filter and ordering commands kept separate from request lifecycle.
extension AdminShippingProfileFilters on AdminShippingProfileViewModel {
  /// Applies a dedicated profile-name filter and resets paging.
  Future<void> filterByName(String name) => load(name: name, offset: 0);

  /// Applies a dedicated fulfillment-type filter and resets paging.
  Future<void> filterByType(String type) => load(type: type, offset: 0);

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
  Future<void> orderBy(AdminShippingProfileOrder order) =>
      load(order: order, offset: 0);

  /// Removes every active filter while preserving search and ordering.
  Future<void> clearFilters() => load(
        name: '',
        type: '',
        createdAt: const AdminDateFilter(),
        updatedAt: const AdminDateFilter(),
        offset: 0,
      );
}
