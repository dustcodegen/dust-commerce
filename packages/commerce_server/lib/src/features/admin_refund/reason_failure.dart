import 'package:dust_dart/db.dart';

/// Stable business reasons a refund reason mutation can be refused.
enum AdminRefundReasonFailure {
  /// The id does not identify an active reason.
  notFound,

  /// Another active reason already owns the code.
  codeConflict,
}

/// Flat error channel for refund reason mutations.
sealed class AdminRefundReasonError {
  const AdminRefundReasonError();
}

/// Expected business refusal safe for transport mapping.
final class AdminRefundReasonRejected extends AdminRefundReasonError {
  /// Creates a refusal with its stable failure.
  const AdminRefundReasonRejected(this.failure);

  /// Business rule that refused the mutation.
  final AdminRefundReasonFailure failure;
}

/// SQLx failure retained while transport returns a safe response.
final class AdminRefundReasonStorage extends AdminRefundReasonError {
  /// Wraps the original SQLx cause.
  const AdminRefundReasonStorage(this.cause);

  /// Original storage failure.
  final SqlxError cause;
}
