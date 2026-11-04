import 'package:dust_dart/db.dart';

/// Stable reasons an order cannot enter Medusa's archived lifecycle.
enum AdminArchiveOrderFailure {
  /// No active order exists for the route id.
  unavailable,

  /// Only completed and canceled orders can be archived in this schema.
  ineligible,
}

/// One flat error channel for whole-order archival.
sealed class AdminArchiveOrderError {
  const AdminArchiveOrderError();
}

/// Expected business refusal safe for transport mapping.
final class AdminArchiveOrderRejected extends AdminArchiveOrderError {
  /// Creates a refusal with its stable reason.
  const AdminArchiveOrderRejected(this.failure);

  /// Business rule that refused the command.
  final AdminArchiveOrderFailure failure;
}

/// SQLx failure retained while transport returns a safe response.
final class AdminArchiveOrderStorage extends AdminArchiveOrderError {
  /// Wraps the original SQLx cause.
  const AdminArchiveOrderStorage(this.cause);

  /// Original database failure.
  final SqlxError cause;
}
