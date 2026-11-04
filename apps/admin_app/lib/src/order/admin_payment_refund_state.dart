import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/serde.dart';

part 'admin_payment_refund_state.g.dart';

/// Lifecycle of refund reason discovery and payment mutation.
enum AdminPaymentRefundStatus {
  /// No refund interaction has started.
  idle,

  /// Merchant reasons are loading.
  loading,

  /// Reasons are ready for form input.
  ready,

  /// One refund command is in flight.
  saving,

  /// Discovery or mutation failed with display-safe copy.
  failed,
}

/// Immutable state owned by the order-detail refund feature.
@Derive([ToString(), Eq(), CopyWith()])
final class AdminPaymentRefundState with _$AdminPaymentRefundState {
  /// Creates refund state without transport or widget objects.
  const AdminPaymentRefundState({
    this.status = AdminPaymentRefundStatus.idle,
    this.reasons = const [],
    this.failure = const None(),
  });

  /// Display-safe failure copy.
  final Option<String> failure;

  /// Active merchant reasons in stable label order.
  final List<AdminRefundReason> reasons;

  /// Current reason-discovery or mutation lifecycle.
  final AdminPaymentRefundStatus status;
}
