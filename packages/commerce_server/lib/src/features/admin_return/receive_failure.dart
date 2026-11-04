import 'package:dust_dart/db.dart';

/// Stable business reasons a return receipt can be refused.
enum AdminReturnReceiveFailure {
  /// The return is terminal or an item/quantity is not receivable.
  invalid,
}

/// One flat error channel for the complete receipt use case.
sealed class AdminReturnReceiveError {
  const AdminReturnReceiveError();
}

/// Expected business refusal safe for transport mapping.
final class AdminReturnReceiveRejected extends AdminReturnReceiveError {
  /// Creates a refusal with its stable reason.
  const AdminReturnReceiveRejected(this.failure);

  /// Business rule that refused the receipt.
  final AdminReturnReceiveFailure failure;
}

/// SQLx failure retained while transport returns a safe response.
final class AdminReturnReceiveStorage extends AdminReturnReceiveError {
  /// Wraps the original SQLx cause.
  const AdminReturnReceiveStorage(this.cause);

  /// Original database failure.
  final SqlxError cause;
}
