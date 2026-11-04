part of 'admin_promotion_view_model.dart';

/// Filter and ordering commands kept separate from request lifecycle.
extension AdminPromotionFilters on AdminPromotionViewModel {
  /// Applies an inclusive creation-time range and resets paging.
  Future<void> filterByCreatedAt(AdminDateFilter value) =>
      load(createdAt: value, offset: 0);

  /// Applies an inclusive update-time range and resets paging.
  Future<void> filterByUpdatedAt(AdminDateFilter value) =>
      load(updatedAt: value, offset: 0);

  /// Applies one allowlisted server ordering and resets paging.
  Future<void> orderBy(AdminPromotionOrder order) =>
      load(order: order, offset: 0);

  /// Removes every active filter while preserving search and ordering.
  Future<void> clearFilters() => load(
        createdAt: const AdminDateFilter(),
        updatedAt: const AdminDateFilter(),
        offset: 0,
      );
}
