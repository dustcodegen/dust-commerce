import 'package:dust_dart/db.dart';

/// Stable reasons fulfillment delivery can be refused.
enum AdminMarkDeliveredFailure {
  /// The route order or fulfillment does not exist.
  unavailable,

  /// The fulfillment is canceled, delivered, or the route input is invalid.
  invalid,

  /// Customer notification was requested without a configured adapter.
  notificationUnavailable,
}

/// One flat error channel for the complete delivery use case.
sealed class AdminMarkDeliveredError {
  const AdminMarkDeliveredError();
}

/// Expected business refusal safe for transport mapping.
final class AdminMarkDeliveredRejected extends AdminMarkDeliveredError {
  /// Creates a refusal with its stable reason.
  const AdminMarkDeliveredRejected(this.failure);

  /// Business rule that refused the command.
  final AdminMarkDeliveredFailure failure;
}

/// SQLx failure retained while transport returns a safe response.
final class AdminMarkDeliveredStorage extends AdminMarkDeliveredError {
  /// Wraps the original SQLx cause.
  const AdminMarkDeliveredStorage(this.cause);

  /// Original database failure.
  final SqlxError cause;
}
