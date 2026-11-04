import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/serde.dart';

part 'admin_customer_group_state.g.dart';

/// Lifecycle of the authenticated merchant customer-group list.
enum AdminCustomerGroupStatus {
  /// No group request has started.
  idle,

  /// A group request is active.
  loading,

  /// The current group page is ready.
  ready,

  /// The request failed with display-safe copy.
  failed,
}

/// Immutable state for Medusa's customer-group table.
@Derive([ToString(), Eq(), CopyWith()])
final class AdminCustomerGroupState with _$AdminCustomerGroupState {
  /// Creates group-list state without transport objects.
  const AdminCustomerGroupState({
    this.status = AdminCustomerGroupStatus.idle,
    this.customerGroups = const [],
    this.count = 0,
    this.limit = 10,
    this.offset = 0,
    this.query = '',
    this.createdAt = const AdminDateFilter(),
    this.updatedAt = const AdminDateFilter(),
    this.order = AdminCustomerGroupOrder.createdAtDesc,
    this.failure = const None(),
  });

  /// Total rows matching the active query.
  final int count;

  /// Creation-time comparison applied by the server.
  final AdminDateFilter createdAt;

  /// Explicit merchant customer-group summaries.
  final List<AdminCustomerGroup> customerGroups;

  /// Display-safe request failure.
  final Option<String> failure;

  /// Server-owned page size matching Medusa's table.
  final int limit;

  /// Number of matching rows skipped.
  final int offset;

  /// Stable allowlisted server ordering.
  final AdminCustomerGroupOrder order;

  /// Normalized group id or name search.
  final String query;

  /// Current request lifecycle.
  final AdminCustomerGroupStatus status;

  /// Update-time comparison applied by the server.
  final AdminDateFilter updatedAt;

  /// Whether another server-owned page exists.
  bool get hasNext => offset + customerGroups.length < count;

  /// Whether a preceding server-owned page exists.
  bool get hasPrevious => offset > 0;

  /// Whether a date filter is active.
  bool get hasFilters => !createdAt.isEmpty || !updatedAt.isEmpty;
}
