import 'package:dust_dart/db.dart';

/// Stable business reasons a promotion cannot be created.
enum AdminPromotionCreateFailure {
  /// An active promotion already owns the requested code.
  codeConflict,

  /// The definition is internally inconsistent.
  invalidDefinition,
}

/// One flat error channel for promotion creation.
sealed class AdminPromotionCreateError {
  const AdminPromotionCreateError();
}

/// Expected business refusal safe for transport mapping.
final class AdminPromotionCreateRejected extends AdminPromotionCreateError {
  /// Creates a refusal with its stable [failure].
  const AdminPromotionCreateRejected(this.failure);

  /// Business rule that refused creation.
  final AdminPromotionCreateFailure failure;
}

/// SQLx failure retained while transport returns a safe response.
final class AdminPromotionCreateStorage extends AdminPromotionCreateError {
  /// Wraps the original SQLx [cause].
  const AdminPromotionCreateStorage(this.cause);

  /// Original database failure.
  final SqlxError cause;
}
