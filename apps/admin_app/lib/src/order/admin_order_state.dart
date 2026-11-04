import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/serde.dart';

part 'admin_order_state.g.dart';

/// Lifecycle of the authenticated merchant order list.
enum AdminOrderListStatus {
  /// No order request has started.
  idle,

  /// An order request is active.
  loading,

  /// The current order page is ready.
  ready,

  /// The request failed with a display-safe message.
  failed,
}

/// Lifecycle of selling-region choices loaded from the Admin API.
enum AdminOrderFilterOptionsStatus {
  /// Region choices have not been requested.
  idle,

  /// Region choices are loading.
  loading,

  /// Region choices are ready for selection.
  ready,

  /// Choices could not be loaded; static filters remain usable.
  failed,
}

/// Immutable state for the Medusa-shaped order table.
@Derive([ToString(), Eq(), CopyWith()])
final class AdminOrderState with _$AdminOrderState {
  /// Creates order-list state without transport objects.
  const AdminOrderState({
    this.status = AdminOrderListStatus.idle,
    this.orders = const [],
    this.count = 0,
    this.limit = 20,
    this.offset = 0,
    this.query = '',
    this.statuses = const [],
    this.regionIds = const [],
    this.salesChannelIds = const [],
    this.createdAt = const AdminDateFilter(),
    this.updatedAt = const AdminDateFilter(),
    this.order = AdminOrderOrder.createdAtDesc,
    this.failure = const None(),
    this.filterOptionsFailure = const None(),
    this.filterOptionsStatus = AdminOrderFilterOptionsStatus.idle,
    this.regions = const [],
    this.salesChannels = const [],
  });

  /// Total rows matching the active query.
  final int count;

  /// Creation-time comparison applied by the server.
  final AdminDateFilter createdAt;

  /// Display-safe request failure.
  final Option<String> failure;

  /// Display-safe failure for dynamic region choices.
  final Option<String> filterOptionsFailure;

  /// Loading state kept separate from the order table request.
  final AdminOrderFilterOptionsStatus filterOptionsStatus;

  /// Server-owned page size.
  final int limit;

  /// Number of matching rows skipped.
  final int offset;

  /// Stable allowlisted server ordering.
  final AdminOrderOrder order;

  /// Explicit merchant order summaries.
  final List<AdminOrder> orders;

  /// Normalized display-id, customer, or email search.
  final String query;

  /// Server-owned selling-region choices used by the Medusa filter menu.
  final List<AdminRegion> regions;

  /// Selected selling-region identifiers.
  final List<String> regionIds;

  /// Server-owned sales-channel choices used by the Medusa filter menu.
  final List<AdminSalesChannel> salesChannels;

  /// Selected commercial-origin identifiers.
  final List<String> salesChannelIds;

  /// Current request lifecycle.
  final AdminOrderListStatus status;

  /// Selected order lifecycle states.
  final List<AdminOrderStatus> statuses;

  /// Update-time comparison applied by the server.
  final AdminDateFilter updatedAt;

  /// Whether another server-owned page exists.
  bool get hasNext => offset + orders.length < count;

  /// Whether a preceding server-owned page exists.
  bool get hasPrevious => offset > 0;

  /// Whether any filter other than search and ordering is active.
  bool get hasFilters =>
      statuses.isNotEmpty ||
      regionIds.isNotEmpty ||
      salesChannelIds.isNotEmpty ||
      !createdAt.isEmpty ||
      !updatedAt.isEmpty;
}
