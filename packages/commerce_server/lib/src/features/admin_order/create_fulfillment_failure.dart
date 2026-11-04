import 'package:dust_dart/db.dart';

/// Stable business reasons fulfillment creation can be refused.
enum AdminCreateFulfillmentFailure {
  /// The route order does not exist or was soft deleted.
  unavailable,

  /// The command, selection, lifecycle, or quantity is invalid.
  invalid,

  /// Customer notification was requested without a configured adapter.
  notificationUnavailable,
}

/// One flat error channel for the complete fulfillment use case.
sealed class AdminCreateFulfillmentError {
  const AdminCreateFulfillmentError();
}

/// Expected business refusal safe for transport mapping.
final class AdminCreateFulfillmentRejected extends AdminCreateFulfillmentError {
  /// Creates a refusal with its stable reason.
  const AdminCreateFulfillmentRejected(this.failure);

  /// Business rule that refused the command.
  final AdminCreateFulfillmentFailure failure;
}

/// SQLx failure retained while transport returns a safe response.
final class AdminCreateFulfillmentStorage extends AdminCreateFulfillmentError {
  /// Wraps the original SQLx cause.
  const AdminCreateFulfillmentStorage(this.cause);

  /// Original database failure.
  final SqlxError cause;
}
