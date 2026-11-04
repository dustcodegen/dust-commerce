import 'package:dust_dart/db.dart';

/// Stable reasons shipment creation can be refused.
enum AdminCreateShipmentFailure {
  /// The route order or fulfillment does not exist.
  unavailable,

  /// Input, ownership, quantity, or lifecycle state is invalid.
  invalid,

  /// Customer notification was requested without a configured adapter.
  notificationUnavailable,
}

/// One flat error channel for the complete shipment use case.
sealed class AdminCreateShipmentError {
  const AdminCreateShipmentError();
}

/// Expected business refusal safe for transport mapping.
final class AdminCreateShipmentRejected extends AdminCreateShipmentError {
  /// Creates a refusal with its stable reason.
  const AdminCreateShipmentRejected(this.failure);

  /// Business rule that refused the command.
  final AdminCreateShipmentFailure failure;
}

/// SQLx failure retained while transport returns a safe response.
final class AdminCreateShipmentStorage extends AdminCreateShipmentError {
  /// Wraps the original SQLx cause.
  const AdminCreateShipmentStorage(this.cause);

  /// Original database failure.
  final SqlxError cause;
}
