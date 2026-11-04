import 'package:dust_dart/db.dart';

/// Why an authenticated customer could not request an ownership transfer.
enum RequestOrderTransferFailure {
  /// No active order has the supplied identifier.
  noOrder,

  /// A canceled order can no longer change owner.
  canceled,

  /// The requesting account already owns the order.
  alreadyOwner,

  /// Another account already has an undecided request for this order.
  activeForAnotherCustomer,

  /// This server cannot deliver the owner decision capability.
  deliveryUnavailable,
}

/// One failure channel for the complete transfer-request use case.
sealed class RequestOrderTransferError {
  const RequestOrderTransferError();
}

/// Expected request refusal that an HTTP handler can map safely.
final class RequestOrderTransferRejected extends RequestOrderTransferError {
  /// Creates a refusal with its stable business reason.
  const RequestOrderTransferRejected(this.failure);

  /// Business rule that refused the request.
  final RequestOrderTransferFailure failure;

  @override
  bool operator ==(Object other) =>
      other is RequestOrderTransferRejected && other.failure == failure;

  @override
  int get hashCode => Object.hash(RequestOrderTransferRejected, failure);
}

/// SQLx failure retained while the transport returns a safe response.
final class RequestOrderTransferStorage extends RequestOrderTransferError {
  /// Wraps the original SQLx cause without exposing it to clients.
  const RequestOrderTransferStorage(this.cause);

  /// Original database error.
  final SqlxError cause;
}

/// Why a transfer capability could not produce the requested decision.
enum DecideOrderTransferFailure {
  /// The order/token pair is absent, expired, or otherwise unusable.
  invalid,

  /// The same capability already produced the opposite final decision.
  alreadyDecided,

  /// The referenced order is no longer available to transfer.
  orderUnavailable,
}

/// One failure channel for accepting or declining a transfer.
sealed class DecideOrderTransferError {
  const DecideOrderTransferError();
}

/// Expected decision refusal that an HTTP handler can map safely.
final class DecideOrderTransferRejected extends DecideOrderTransferError {
  /// Creates a refusal with its stable business reason.
  const DecideOrderTransferRejected(this.failure);

  /// Business rule that refused the decision.
  final DecideOrderTransferFailure failure;

  @override
  bool operator ==(Object other) =>
      other is DecideOrderTransferRejected && other.failure == failure;

  @override
  int get hashCode => Object.hash(DecideOrderTransferRejected, failure);
}

/// SQLx failure retained while the transport returns a safe response.
final class DecideOrderTransferStorage extends DecideOrderTransferError {
  /// Wraps the original SQLx cause without exposing it to clients.
  const DecideOrderTransferStorage(this.cause);

  /// Original database error.
  final SqlxError cause;
}
