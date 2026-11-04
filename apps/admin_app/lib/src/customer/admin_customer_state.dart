import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/serde.dart';

part 'admin_customer_state.g.dart';

/// Lifecycle of the authenticated merchant customer list.
enum AdminCustomerListStatus {
  /// No customer request has started.
  idle,

  /// A customer request is active.
  loading,

  /// The current customer page is ready.
  ready,

  /// The request failed with a display-safe message.
  failed,
}

/// Immutable state for the Medusa-shaped customer table.
@Derive([ToString(), Eq(), CopyWith()])
final class AdminCustomerState with _$AdminCustomerState {
  /// Creates customer-list state without transport objects.
  const AdminCustomerState({
    this.status = AdminCustomerListStatus.idle,
    this.customers = const [],
    this.count = 0,
    this.limit = 20,
    this.offset = 0,
    this.query = '',
    this.hasAccount = const None(),
    this.createdAt = const AdminDateFilter(),
    this.updatedAt = const AdminDateFilter(),
    this.order = AdminCustomerOrder.createdAtDesc,
    this.failure = const None(),
  });

  /// Total rows matching the active query.
  final int count;

  /// Creation-time comparison applied by the server.
  final AdminDateFilter createdAt;

  /// Explicit merchant customer summaries.
  final List<AdminCustomer> customers;

  /// Display-safe request failure.
  final Option<String> failure;

  /// Registered/guest filter, or no account constraint.
  final Option<bool> hasAccount;

  /// Server-owned page size.
  final int limit;

  /// Number of matching rows skipped.
  final int offset;

  /// Stable allowlisted server ordering.
  final AdminCustomerOrder order;

  /// Normalized customer identity search.
  final String query;

  /// Current request lifecycle.
  final AdminCustomerListStatus status;

  /// Update-time comparison applied by the server.
  final AdminDateFilter updatedAt;

  /// Whether another server-owned page exists.
  bool get hasNext => offset + customers.length < count;

  /// Whether a preceding server-owned page exists.
  bool get hasPrevious => offset > 0;

  /// Whether any filter other than search and ordering is active.
  bool get hasFilters =>
      hasAccount is Some<bool> || !createdAt.isEmpty || !updatedAt.isEmpty;
}
