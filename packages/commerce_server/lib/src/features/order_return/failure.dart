import 'package:dust_dart/db.dart';

/// Stable business reasons a return request can be refused.
enum OrderReturnFailure {
  /// The order is absent or belongs to another customer.
  noOrder,

  /// Payment is not captured or a selected item has not been delivered.
  ineligibleOrder,

  /// An item is absent, duplicated, or belongs to another order.
  invalidItem,

  /// A supplied return reason is not active.
  invalidReason,

  /// Existing returns consume some or all delivered quantity.
  quantityUnavailable,
}

/// One error channel for the complete request-return use case.
sealed class OrderReturnError {
  const OrderReturnError();
}

/// Expected business refusal safe for transport mapping.
final class OrderReturnRejected extends OrderReturnError {
  /// Creates a refusal with its stable reason.
  const OrderReturnRejected(this.failure);

  /// Business rule that refused the request.
  final OrderReturnFailure failure;
}

/// SQLx failure retained while transport returns a safe response.
final class OrderReturnStorage extends OrderReturnError {
  /// Wraps the original SQLx cause.
  const OrderReturnStorage(this.cause);

  /// Original database failure.
  final SqlxError cause;
}
