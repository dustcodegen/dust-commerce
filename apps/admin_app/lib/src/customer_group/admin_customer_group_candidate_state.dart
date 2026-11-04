import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/serde.dart';

part 'admin_customer_group_candidate_state.g.dart';

/// Lifecycle of Medusa's customer-group member candidate table.
enum AdminCustomerGroupCandidateStatus {
  /// No candidate request has started.
  idle,

  /// One candidate page is loading.
  loading,

  /// Candidate rows are ready.
  ready,

  /// Candidate loading failed.
  failed,
}

/// Immutable list state for the Add Customers focus surface.
@Derive([ToString(), Eq(), CopyWith()])
final class AdminCustomerGroupCandidateState
    with _$AdminCustomerGroupCandidateState {
  /// Creates empty candidate-list state.
  const AdminCustomerGroupCandidateState({
    this.status = AdminCustomerGroupCandidateStatus.idle,
    this.customers = const [],
    this.count = 0,
    this.limit = 10,
    this.offset = 0,
    this.query = '',
    this.hasAccount = const None(),
    this.order = AdminCustomerOrder.createdAtDesc,
    this.failure = const None(),
  });

  /// Total matching active customers.
  final int count;

  /// Current allowlisted customer page.
  final List<AdminCustomer> customers;

  /// Display-safe list failure.
  final Option<String> failure;

  /// Registered/guest candidate filter.
  final Option<bool> hasAccount;

  /// Fixed Medusa focus-table page size.
  final int limit;

  /// Number of matching rows skipped.
  final int offset;

  /// Allowlisted customer ordering.
  final AdminCustomerOrder order;

  /// Normalized candidate search query.
  final String query;

  /// Current candidate-list lifecycle.
  final AdminCustomerGroupCandidateStatus status;

  /// Whether another page exists.
  bool get hasNext => offset + customers.length < count;

  /// Whether an earlier page exists.
  bool get hasPrevious => offset > 0;
}
