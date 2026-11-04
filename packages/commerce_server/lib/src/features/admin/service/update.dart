import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin/model.dart';
import 'package:commerce_server/src/features/admin/repository/repository.dart';
import 'package:commerce_server/src/infra/database.dart';
import 'package:commerce_server/src/infra/option.dart';
import 'package:dust_dart/db.dart';

/// Business reason a valid product update could not be applied.
enum AdminUpdateProductFailure {
  /// No active product owns the requested identifier.
  notFound,

  /// Another active product already owns the requested handle.
  handleConflict,
}

/// Atomically replaces supported general fields and returns fresh detail.
Future<
    Result<Result<AdminProductDetailResponse, AdminUpdateProductFailure>,
        SqlxError>> updateAdminProduct(
  CommerceDatabase database,
  String id,
  AdminUpdateProduct input,
) =>
    database.transaction((tx) async {
      final updated = await AdminProductUpdateRepository(tx).updateGeneral(
        id,
        input.title,
        input.handle,
        input.subtitle,
        input.material,
        input.description,
        input.discountable ? 1 : 0,
        input.status.name,
      );
      if (updated case Err(:final error)) return Err(error);

      if ((updated as Ok<ExecResult, SqlxError>).value.rowsAffected == 0) {
        final existing = await AdminProductReadRepository(tx).findById(id);
        if (existing case Err(:final error)) return Err(error);
        return Ok(optionOf(
          (existing as Ok<AdminProductDetailResponse?, SqlxError>).value,
        ) is Some<AdminProductDetailResponse>
            ? const Err(AdminUpdateProductFailure.handleConflict)
            : const Err(AdminUpdateProductFailure.notFound));
      }

      final refreshed = await AdminProductReadRepository(tx).findById(id);
      if (refreshed case Err(:final error)) return Err(error);
      return switch (optionOf(
        (refreshed as Ok<AdminProductDetailResponse?, SqlxError>).value,
      )) {
        Some(value: final product) => Ok(Ok(product)),
        None() => const Ok(Err(AdminUpdateProductFailure.notFound)),
      };
    });
