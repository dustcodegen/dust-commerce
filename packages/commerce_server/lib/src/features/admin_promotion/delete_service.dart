import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin_promotion/delete_repository.dart';
import 'package:dust_dart/db.dart';

/// Why one promotion cannot be retired.
enum AdminPromotionDeleteFailure {
  /// The promotion is missing or already retired.
  notFound,
}

/// Error crossing the promotion-retirement boundary.
sealed class AdminPromotionDeleteError {
  const AdminPromotionDeleteError();
}

/// Expected business refusal safe for transport mapping.
final class AdminPromotionDeleteRejected extends AdminPromotionDeleteError {
  /// Creates a safe business refusal.
  const AdminPromotionDeleteRejected(this.failure);

  /// Stable refusal reason for transport mapping.
  final AdminPromotionDeleteFailure failure;
}

/// SQLx failure retained for the internal error boundary.
final class AdminPromotionDeleteStorage extends AdminPromotionDeleteError {
  /// Creates a storage failure wrapper.
  const AdminPromotionDeleteStorage(this.cause);

  /// Original SQLx failure for internal diagnostics.
  final SqlxError cause;
}

/// Retires one active promotion without erasing redemption history.
Future<Result<AdminPromotionDeleted, AdminPromotionDeleteError>>
    deleteAdminPromotion(
        AdminPromotionDeleteRepository repository, String id) async {
  if (id.isEmpty || id.trim() != id) {
    return const Err(AdminPromotionDeleteRejected(
      AdminPromotionDeleteFailure.notFound,
    ));
  }
  final result = await repository.retire(id);
  if (result case Err(:final error)) {
    return Err(AdminPromotionDeleteStorage(error));
  }
  if ((result as Ok<ExecResult, SqlxError>).value.rowsAffected == 0) {
    return const Err(AdminPromotionDeleteRejected(
      AdminPromotionDeleteFailure.notFound,
    ));
  }
  return Ok(AdminPromotionDeleted(id: id));
}
