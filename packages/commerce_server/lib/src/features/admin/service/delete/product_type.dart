import 'package:commerce_server/src/features/admin/repository/repository.dart';
import 'package:commerce_server/src/infra/database.dart';
import 'package:dust_dart/db.dart';

/// Business reason a product type could not be retired.
enum AdminDeleteProductTypeFailure {
  /// No active product type owns the identifier.
  notFound,
}

/// Error crossing the Admin product-type deletion boundary.
sealed class AdminDeleteProductTypeError {
  /// Creates one product-type error.
  const AdminDeleteProductTypeError();
}

/// A business rejection that is safe to expose to the handler.
final class AdminDeleteProductTypeRejected extends AdminDeleteProductTypeError {
  /// Creates one business rejection.
  const AdminDeleteProductTypeRejected(this.failure);

  /// The stable business reason.
  final AdminDeleteProductTypeFailure failure;
}

/// A storage failure retained for logging without exposing SQL details.
final class AdminDeleteProductTypeStorage extends AdminDeleteProductTypeError {
  /// Creates one storage failure.
  const AdminDeleteProductTypeStorage(this.cause);

  /// The original SQLx failure.
  final SqlxError cause;
}

/// Soft-deletes one product type while retaining historical references.
Future<Result<void, AdminDeleteProductTypeError>> deleteAdminProductType(
  CommerceDatabase database,
  String id,
) async {
  final retired = await AdminProductTypeDeleteRepository(
    database.executor,
  ).retireProductType(id);
  if (retired case Err(:final error)) {
    return Err(AdminDeleteProductTypeStorage(error));
  }
  return (retired as Ok<ExecResult, SqlxError>).value.rowsAffected == 1
      ? const Ok(null)
      : const Err(
          AdminDeleteProductTypeRejected(
              AdminDeleteProductTypeFailure.notFound),
        );
}
