part of 'admin_customer_group_view_model.dart';

/// Medusa group-table filter mutations kept out of widget state.
extension AdminCustomerGroupFilters on AdminCustomerGroupViewModel {
  /// Replaces creation-time bounds.
  Future<void> filterByCreatedAt({
    Option<DateTime> from = const None(),
    Option<DateTime> to = const None(),
  }) =>
      load(
        createdAt: AdminDateFilter(
          greaterThanOrEqual: from,
          lessThanOrEqual: to,
        ),
        offset: 0,
      );

  /// Replaces update-time bounds.
  Future<void> filterByUpdatedAt({
    Option<DateTime> from = const None(),
    Option<DateTime> to = const None(),
  }) =>
      load(
        updatedAt: AdminDateFilter(
          greaterThanOrEqual: from,
          lessThanOrEqual: to,
        ),
        offset: 0,
      );

  /// Replaces the allowlisted server ordering.
  Future<void> orderBy(AdminCustomerGroupOrder value) =>
      load(order: value, offset: 0);

  /// Clears date filters while retaining search and ordering.
  Future<void> clearFilters() => load(
        createdAt: const AdminDateFilter(),
        updatedAt: const AdminDateFilter(),
        offset: 0,
      );
}
