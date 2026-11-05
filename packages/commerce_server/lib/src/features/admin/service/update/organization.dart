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

/// Error crossing the Admin product-organization update boundary.
sealed class AdminUpdateProductOrganizationError {
  /// Creates one product-organization update error.
  const AdminUpdateProductOrganizationError();
}

/// A business rejection that is safe to expose to the handler.
final class AdminUpdateProductOrganizationRejected
    extends AdminUpdateProductOrganizationError {
  /// Creates one business rejection.
  const AdminUpdateProductOrganizationRejected(this.failure);

  /// The stable business reason.
  final AdminUpdateProductOrganizationFailure failure;
}

/// A storage failure retained for logging without exposing SQL details.
final class AdminUpdateProductOrganizationStorage
    extends AdminUpdateProductOrganizationError {
  /// Creates one storage failure.
  const AdminUpdateProductOrganizationStorage(this.cause);

  /// The original SQLx failure.
  final SqlxError cause;
}

/// Replaces only a product's classification and returns fresh detail.
Future<Result<AdminProductDetailResponse, AdminUpdateProductOrganizationError>>
    updateAdminProductOrganization(
  CommerceDatabase database,
  String productId,
  AdminUpdateProductOrganization input,
) =>
        transactionResult<AdminProductDetailResponse,
            AdminUpdateProductOrganizationError>(
          database,
          (tx) async {
            final updated = await AdminProductUpdateRepository(tx)
                .updateOrganization(productId, input.typeId);
            if (updated case Err(:final error)) {
              return Err(AdminUpdateProductOrganizationStorage(error));
            }

            final refreshed =
                await AdminProductReadRepository(tx).findById(productId);
            if (refreshed case Err(:final error)) {
              return Err(AdminUpdateProductOrganizationStorage(error));
            }
            final product = optionOf(
              (refreshed as Ok<AdminProductDetailResponse?, SqlxError>).value,
            );
            if ((updated as Ok<ExecResult, SqlxError>).value.rowsAffected ==
                0) {
              return product is None<AdminProductDetailResponse>
                  ? const Err(AdminUpdateProductOrganizationRejected(
                      AdminUpdateProductOrganizationFailure.notFound,
                    ))
                  : const Err(AdminUpdateProductOrganizationRejected(
                      AdminUpdateProductOrganizationFailure.invalidProductType,
                    ));
            }
            return switch (product) {
              Some(:final value) => Ok(value),
              None() => const Err(AdminUpdateProductOrganizationRejected(
                  AdminUpdateProductOrganizationFailure.notFound,
                )),
            };
          },
          storageError: AdminUpdateProductOrganizationStorage.new,
        );
