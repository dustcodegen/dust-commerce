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

/// Error crossing the Admin product-update boundary.
sealed class AdminUpdateProductError {
  /// Creates one product-update error.
  const AdminUpdateProductError();
}

/// A business rejection that is safe to expose to the handler.
final class AdminUpdateProductRejected extends AdminUpdateProductError {
  /// Creates one business rejection.
  const AdminUpdateProductRejected(this.failure);

  /// The stable business reason.
  final AdminUpdateProductFailure failure;
}

/// A storage failure retained for logging without exposing SQL details.
final class AdminUpdateProductStorage extends AdminUpdateProductError {
  /// Creates one storage failure.
  const AdminUpdateProductStorage(this.cause);

  /// The original SQLx failure.
  final SqlxError cause;
}

/// Atomically replaces supported general fields and returns fresh detail.
Future<Result<AdminProductDetailResponse, AdminUpdateProductError>>
    updateAdminProduct(
  CommerceDatabase database,
  String id,
  AdminUpdateProduct input,
) =>
        transactionResult<AdminProductDetailResponse, AdminUpdateProductError>(
          database,
          (tx) async {
            final updated =
                await AdminProductUpdateRepository(tx).updateGeneral(
              id,
              input.title,
              input.handle,
              input.subtitle,
              input.material,
              input.description,
              input.discountable ? 1 : 0,
              input.status.name,
            );
            if (updated case Err(:final error)) {
              return Err(AdminUpdateProductStorage(error));
            }

            if ((updated as Ok<ExecResult, SqlxError>).value.rowsAffected ==
                0) {
              final existing =
                  await AdminProductReadRepository(tx).findById(id);
              if (existing case Err(:final error)) {
                return Err(AdminUpdateProductStorage(error));
              }
              return optionOf(
                (existing as Ok<AdminProductDetailResponse?, SqlxError>).value,
              ) is Some<AdminProductDetailResponse>
                  ? const Err(AdminUpdateProductRejected(
                      AdminUpdateProductFailure.handleConflict,
                    ))
                  : const Err(AdminUpdateProductRejected(
                      AdminUpdateProductFailure.notFound,
                    ));
            }

            final refreshed = await AdminProductReadRepository(tx).findById(id);
            if (refreshed case Err(:final error)) {
              return Err(AdminUpdateProductStorage(error));
            }
            return switch (optionOf(
              (refreshed as Ok<AdminProductDetailResponse?, SqlxError>).value,
            )) {
              Some(value: final product) => Ok(product),
              None() => const Err(
                  AdminUpdateProductRejected(
                      AdminUpdateProductFailure.notFound),
                ),
            };
          },
          storageError: AdminUpdateProductStorage.new,
        );
