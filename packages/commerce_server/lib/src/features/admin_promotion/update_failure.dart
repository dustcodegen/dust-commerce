import 'package:dust_dart/db.dart';

/// Stable business reasons a promotion cannot be updated.
enum AdminPromotionUpdateFailure {
  /// The promotion is missing or already retired.
  notFound,

  /// Another active promotion already owns the requested code.
  codeConflict,

  /// The requested definition contradicts the existing redemption history.
  invalidDefinition,
}

/// One flat error channel for promotion updates.
sealed class AdminPromotionUpdateError {
  const AdminPromotionUpdateError();
}

/// Expected business refusal safe for transport mapping.
final class AdminPromotionUpdateRejected extends AdminPromotionUpdateError {
  /// Creates a refusal with its stable [failure].
  const AdminPromotionUpdateRejected(this.failure);

  /// Business rule that refused the update.
  final AdminPromotionUpdateFailure failure;
}

/// SQLx failure retained for the internal error boundary.
final class AdminPromotionUpdateStorage extends AdminPromotionUpdateError {
  /// Wraps the original SQLx [cause].
  const AdminPromotionUpdateStorage(this.cause);

  /// Original database failure.
  final SqlxError cause;
}
