import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/serde.dart';

part 'admin_customer_service_state.g.dart';

/// Lifecycle of the protected merchant support inbox.
enum AdminCustomerServiceListStatus {
  /// No inbox request has started.
  idle,

  /// One inbox page is loading.
  loading,

  /// The current inbox page is ready.
  ready,

  /// Loading failed with display-safe feedback.
  failed,
}

/// Immutable merchant support-inbox state without transport objects.
@Derive([ToString(), Eq(), CopyWith()])
final class AdminCustomerServiceState with _$AdminCustomerServiceState {
  /// Creates the default newest-first inbox state.
  const AdminCustomerServiceState({
    this.status = AdminCustomerServiceListStatus.idle,
    this.requests = const [],
    this.count = 0,
    this.limit = 20,
    this.offset = 0,
    this.query = '',
    this.statuses = const [],
    this.order = AdminCustomerServiceOrder.createdAtDesc,
    this.updatingId = const None(),
    this.failure = const None(),
  });

  /// Total requests matching the active query.
  final int count;

  /// Display-safe list or mutation failure.
  final Option<String> failure;

  /// Server-owned page size.
  final int limit;

  /// Number of matching requests skipped.
  final int offset;

  /// Stable allowlisted server ordering.
  final AdminCustomerServiceOrder order;

  /// Normalized id, customer, subject, or order search.
  final String query;

  /// Explicit Admin-only request rows.
  final List<AdminCustomerServiceRequest> requests;

  /// Active triage lifecycle filters.
  final List<AdminCustomerServiceStatus> statuses;

  /// Current inbox request lifecycle.
  final AdminCustomerServiceListStatus status;

  /// Request whose lifecycle mutation is active.
  final Option<String> updatingId;

  /// Whether another server-owned page exists.
  bool get hasNext => offset + requests.length < count;

  /// Whether a preceding server-owned page exists.
  bool get hasPrevious => offset > 0;

  /// Whether a status constraint is active.
  bool get hasFilters => statuses.isNotEmpty;

  /// Whether [id] is the request currently changing lifecycle.
  bool isUpdating(String id) => updatingId == Some(id);
}
