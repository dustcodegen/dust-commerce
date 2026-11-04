import 'package:dust_dart/db.dart';

/// Stable reasons whole-order cancellation can be refused.
enum AdminCancelOrderFailure {
  /// No active order exists for the route id.
  unavailable,

  /// The order already reached the canceled terminal state.
  alreadyCanceled,

  /// Completed orders must use the return workflow instead.
  completed,

  /// Every fulfillment must be canceled before the parent order.
  activeFulfillments,

  /// The payment provider has no safe cancellation/refund adapter.
  providerUnavailable,

  /// Stored payment facts contradict one another and require reconciliation.
  invalidPayment,
}

/// One flat error channel for whole-order cancellation.
sealed class AdminCancelOrderError {
  const AdminCancelOrderError();
}

/// Expected business refusal safe for transport mapping.
final class AdminCancelOrderRejected extends AdminCancelOrderError {
  /// Creates a refusal with its stable reason.
  const AdminCancelOrderRejected(this.failure);

  /// Business rule that refused the command.
  final AdminCancelOrderFailure failure;
}

/// SQLx failure retained while transport returns a safe response.
final class AdminCancelOrderStorage extends AdminCancelOrderError {
  /// Wraps the original SQLx cause.
  const AdminCancelOrderStorage(this.cause);

  /// Original database failure.
  final SqlxError cause;
}
