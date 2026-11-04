import 'package:dust_dart/db.dart';

/// Stable reasons fulfillment cancellation can be refused.
enum AdminCancelFulfillmentFailure {
  /// The route order or fulfillment does not exist.
  unavailable,

  /// The fulfillment is already shipped, delivered, canceled, or invalid.
  invalid,

  /// Customer notification was requested without a configured adapter.
  notificationUnavailable,

  /// The fulfillment provider has no safe cancellation adapter.
  providerUnavailable,
}

/// One flat error channel for the complete cancellation use case.
sealed class AdminCancelFulfillmentError {
  const AdminCancelFulfillmentError();
}

/// Expected business refusal safe for transport mapping.
final class AdminCancelFulfillmentRejected extends AdminCancelFulfillmentError {
  /// Creates a refusal with its stable reason.
  const AdminCancelFulfillmentRejected(this.failure);

  /// Business rule that refused the command.
  final AdminCancelFulfillmentFailure failure;
}

/// SQLx failure retained while transport returns a safe response.
final class AdminCancelFulfillmentStorage extends AdminCancelFulfillmentError {
  /// Wraps the original SQLx cause.
  const AdminCancelFulfillmentStorage(this.cause);

  /// Original database failure.
  final SqlxError cause;
}
