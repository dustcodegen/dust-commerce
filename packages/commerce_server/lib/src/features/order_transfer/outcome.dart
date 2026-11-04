import 'package:commerce_server/src/features/order_transfer/failure.dart';
import 'package:commerce_server/src/features/order_transfer/model.dart';

/// Transaction value that commits request cleanup without nesting `Result`.
sealed class RequestOrderTransferOutcome {
  const RequestOrderTransferOutcome();
}

/// Persisted transfer request.
final class RequestOrderTransferReady extends RequestOrderTransferOutcome {
  /// Creates a successful transaction value.
  const RequestOrderTransferReady(this.response);

  /// Persisted response.
  final OrderTransferResponse response;
}

/// Expected request refusal whose cleanup still commits.
final class RequestOrderTransferDenied extends RequestOrderTransferOutcome {
  /// Creates a refused transaction value.
  const RequestOrderTransferDenied(this.failure);

  /// Business reason for the refusal.
  final RequestOrderTransferFailure failure;
}

/// Transaction value that commits decision cleanup without nesting `Result`.
sealed class DecideOrderTransferOutcome {
  const DecideOrderTransferOutcome();
}

/// Persisted transfer decision.
final class DecideOrderTransferReady extends DecideOrderTransferOutcome {
  /// Creates a successful transaction value.
  const DecideOrderTransferReady(this.response);

  /// Persisted response.
  final OrderTransferResponse response;
}

/// Expected decision refusal whose cleanup still commits.
final class DecideOrderTransferDenied extends DecideOrderTransferOutcome {
  /// Creates a refused transaction value.
  const DecideOrderTransferDenied(this.failure);

  /// Business reason for the refusal.
  final DecideOrderTransferFailure failure;
}
