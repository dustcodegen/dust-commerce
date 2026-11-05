import 'package:dust_dart/db.dart';

/// Business reason a product-option replacement could not be committed.
enum AdminUpdateProductOptionDetailFailure {
  /// The title or values are empty, too long, or duplicated.
  invalid,

  /// No active product option owns the identifier.
  notFound,

  /// Another global product option already uses the requested title.
  titleConflict,

  /// A live variant still selects one of the removed values.
  valueInUse,
}

/// Error crossing the Admin product-option update boundary.
sealed class AdminUpdateProductOptionDetailError {
  /// Creates one product-option error.
  const AdminUpdateProductOptionDetailError();
}

/// A business rejection that is safe to expose to the handler.
final class AdminUpdateProductOptionDetailRejected
    extends AdminUpdateProductOptionDetailError {
  /// Creates one business rejection.
  const AdminUpdateProductOptionDetailRejected(this.failure);

  /// The stable business reason.
  final AdminUpdateProductOptionDetailFailure failure;
}

/// A storage failure retained for logging without exposing SQL details.
final class AdminUpdateProductOptionDetailStorage
    extends AdminUpdateProductOptionDetailError {
  /// Creates one storage failure.
  const AdminUpdateProductOptionDetailStorage(this.cause);

  /// The original SQLx failure.
  final SqlxError cause;
}
