import 'package:dust_dart/db.dart';

/// Stable reasons an independent refund can be refused.
enum AdminPaymentRefundFailure {
  /// No active payment exists for the route id.
  unavailable,

  /// Stored order and payment facts contradict one another.
  invalidPayment,

  /// The payment has not reached a captured state.
  notCaptured,

  /// The requested amount is non-positive or exceeds remaining funds.
  invalidAmount,

  /// The selected merchant reason is absent or retired.
  unavailableReason,

  /// The current payment adapter cannot safely refund funds.
  providerUnavailable,
}

/// One flat error channel for refund business and storage failures.
sealed class AdminPaymentRefundError {
  const AdminPaymentRefundError();
}

/// Expected refusal safe for transport mapping.
final class AdminPaymentRefundRejected extends AdminPaymentRefundError {
  /// Creates a refusal with its stable reason.
  const AdminPaymentRefundRejected(this.failure);

  /// Rule that refused the command.
  final AdminPaymentRefundFailure failure;
}

/// SQLx failure retained while transport returns a safe response.
final class AdminPaymentRefundStorage extends AdminPaymentRefundError {
  /// Wraps the original database cause.
  const AdminPaymentRefundStorage(this.cause);

  /// Original storage failure.
  final SqlxError cause;
}
