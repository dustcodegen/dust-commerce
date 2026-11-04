part of 'admin_customer_view_model.dart';

/// Medusa customer-table filter mutations kept out of widget state.
extension AdminCustomerFilters on AdminCustomerViewModel {
  /// Replaces the registered/guest account filter.
  Future<void> filterByAccount(Option<bool> value) =>
      load(hasAccount: value, offset: 0);

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
  Future<void> orderBy(AdminCustomerOrder value) =>
      load(order: value, offset: 0);

  /// Clears account and date filters while retaining search and ordering.
  Future<void> clearFilters() => load(
        hasAccount: const None(),
        createdAt: const AdminDateFilter(),
        updatedAt: const AdminDateFilter(),
        offset: 0,
      );
}
