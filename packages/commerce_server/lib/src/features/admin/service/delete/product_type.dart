import 'package:commerce_server/src/features/admin/repository/repository.dart';
import 'package:commerce_server/src/infra/database.dart';
import 'package:dust_dart/db.dart';

/// Business reason a product type could not be retired.
enum AdminDeleteProductTypeFailure {
  /// No active product type owns the identifier.
  notFound,
}

/// Soft-deletes one product type while retaining historical references.
Future<Result<Result<void, AdminDeleteProductTypeFailure>, SqlxError>>
    deleteAdminProductType(CommerceDatabase database, String id) async {
  final retired = await AdminProductTypeDeleteRepository(
    database.executor,
  ).retireProductType(id);
  if (retired case Err(:final error)) return Err(error);
  return (retired as Ok<ExecResult, SqlxError>).value.rowsAffected == 1
      ? const Ok(Ok(null))
      : const Ok(Err(AdminDeleteProductTypeFailure.notFound));
}
