import 'package:dust_dart/db.dart';

/// Stable reasons an order cannot enter Medusa's completed lifecycle.
enum AdminCompleteOrderFailure {
  /// No active order exists for the route id.
  unavailable,

  /// A canceled order cannot be completed later.
  canceled,
}

/// One flat error channel for whole-order completion.
sealed class AdminCompleteOrderError {
  const AdminCompleteOrderError();
}

/// Expected business refusal safe for transport mapping.
final class AdminCompleteOrderRejected extends AdminCompleteOrderError {
  /// Creates a refusal with its stable reason.
  const AdminCompleteOrderRejected(this.failure);

  /// Business rule that refused the command.
  final AdminCompleteOrderFailure failure;
}

/// SQLx failure retained while transport returns a safe response.
final class AdminCompleteOrderStorage extends AdminCompleteOrderError {
  /// Wraps the original SQLx cause.
  const AdminCompleteOrderStorage(this.cause);

  /// Original database failure.
  final SqlxError cause;
}
