import 'package:commerce_server/src/features/order_return/failure.dart';
import 'package:commerce_server/src/features/order_return/model.dart';

/// Transaction value that keeps domain refusal out of nested `Result` types.
sealed class OrderReturnOutcome {
  const OrderReturnOutcome();
}

/// Persisted return request.
final class OrderReturnReady extends OrderReturnOutcome {
  /// Creates a successful transaction value.
  const OrderReturnReady(this.response);

  /// Direct SQLx Store response.
  final OrderReturnResponse response;
}

/// Expected refusal that completes without a storage failure.
final class OrderReturnDenied extends OrderReturnOutcome {
  /// Creates a denied transaction value.
  const OrderReturnDenied(this.failure);

  /// Stable business reason.
  final OrderReturnFailure failure;
}
