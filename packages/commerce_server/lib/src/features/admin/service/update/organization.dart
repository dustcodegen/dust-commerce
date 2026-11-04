import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin/model.dart';
import 'package:commerce_server/src/features/admin/repository/repository.dart';
import 'package:commerce_server/src/infra/database.dart';
import 'package:commerce_server/src/infra/option.dart';
import 'package:dust_dart/db.dart';

/// Business reason a product organization update could not be applied.
enum AdminUpdateProductOrganizationFailure {
  /// No active product owns the requested identifier.
  notFound,

  /// The requested product type is missing or retired.
  invalidProductType,
}

/// Replaces only a product's classification and returns fresh detail.
Future<
    Result<
        Result<AdminProductDetailResponse,
            AdminUpdateProductOrganizationFailure>,
        SqlxError>> updateAdminProductOrganization(
  CommerceDatabase database,
  String productId,
  AdminUpdateProductOrganization input,
) =>
    database.transaction((tx) async {
      final updated = await AdminProductUpdateRepository(tx)
          .updateOrganization(productId, input.typeId);
      if (updated case Err(:final error)) return Err(error);

      final refreshed =
          await AdminProductReadRepository(tx).findById(productId);
      if (refreshed case Err(:final error)) return Err(error);
      final product = optionOf(
        (refreshed as Ok<AdminProductDetailResponse?, SqlxError>).value,
      );
      if ((updated as Ok<ExecResult, SqlxError>).value.rowsAffected == 0) {
        return product is None<AdminProductDetailResponse>
            ? const Ok(Err(AdminUpdateProductOrganizationFailure.notFound))
            : const Ok(
                Err(AdminUpdateProductOrganizationFailure.invalidProductType),
              );
      }
      return switch (product) {
        Some(:final value) => Ok(Ok(value)),
        None() => const Ok(Err(AdminUpdateProductOrganizationFailure.notFound)),
      };
    });
