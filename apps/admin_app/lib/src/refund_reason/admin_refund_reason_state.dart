import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/derive.dart';

part 'admin_refund_reason_state.g.dart';

/// Lifecycle of the protected refund-reason table.
enum AdminRefundReasonLoadStatus {
  /// No request has been made yet.
  idle,

  /// A request is in flight.
  loading,

  /// The latest request completed successfully.
  ready,

  /// The latest request failed.
  failed,
}

/// Immutable state for merchant refund reasons.
@Derive([ToString(), Eq(), CopyWith()])
final class AdminRefundReasonState with _$AdminRefundReasonState {
  /// Creates an empty reason-table state.
  const AdminRefundReasonState({
    this.status = AdminRefundReasonLoadStatus.idle,
    this.reasons = const [],
    this.count = 0,
    this.limit = 20,
    this.offset = 0,
    this.query = '',
    this.failure = const None(),
    this.busyId = const None(),
  });

  /// Total matching active reasons.
  final int count;

  /// Display-safe failure message.
  final Option<String> failure;

  /// Id currently being retired, if any.
  final Option<String> busyId;

  /// Maximum records requested per page.
  final int limit;

  /// Number of records skipped.
  final int offset;

  /// Current search query.
  final String query;

  /// Active merchant reasons.
  final List<AdminRefundReason> reasons;

  /// Current request lifecycle.
  final AdminRefundReasonLoadStatus status;

  /// Whether a next page exists.
  bool get hasNext => offset + reasons.length < count;

  /// Whether a previous page exists.
  bool get hasPrevious => offset > 0;
}
