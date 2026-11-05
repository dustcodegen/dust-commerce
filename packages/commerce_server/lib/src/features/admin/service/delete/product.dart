import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin/repository/delete/product.dart';
import 'package:commerce_server/src/infra/database.dart';
import 'package:dust_dart/db.dart';

/// Business reason an active product could not be retired.
enum AdminDeleteProductFailure {
  /// No active product owns the requested identifier.
  notFound,
}

/// Error crossing the Admin product-deletion boundary.
sealed class AdminDeleteProductError {
  /// Creates one product-deletion error.
  const AdminDeleteProductError();
}

/// A business rejection that is safe to expose to the handler.
final class AdminDeleteProductRejected extends AdminDeleteProductError {
  /// Creates one business rejection.
  const AdminDeleteProductRejected(this.failure);

  /// The stable business reason.
  final AdminDeleteProductFailure failure;
}

/// A storage failure retained for logging without exposing SQL details.
final class AdminDeleteProductStorage extends AdminDeleteProductError {
  /// Creates one storage failure.
  const AdminDeleteProductStorage(this.cause);

  /// The original SQLx failure.
  final SqlxError cause;
}

/// Soft-deletes one product graph while retaining historical rows.
Future<Result<AdminProductDeleted, AdminDeleteProductError>> deleteAdminProduct(
    CommerceDatabase database, String productId) async {
  return transactionResult<AdminProductDeleted, AdminDeleteProductError>(
    database,
    (tx) async {
      final deletes = AdminProductDeleteRepository(tx);
      final product = await deletes.product(productId);
      if (product case Err(:final error)) {
        return Err(AdminDeleteProductStorage(error));
      }
      if ((product as Ok<ExecResult, SqlxError>).value.rowsAffected == 0) {
        return const Err(
          AdminDeleteProductRejected(AdminDeleteProductFailure.notFound),
        );
      }

      final operations = [
        () => deletes.exclusiveOptionValues(productId),
        () => deletes.exclusiveOptions(productId),
        () => deletes.productOptionValues(productId),
        () => deletes.productOptions(productId),
        () => deletes.images(productId),
        () => deletes.variants(productId),
      ];
      for (final operation in operations) {
        final result = await operation();
        if (result case Err(:final error)) {
          return Err(AdminDeleteProductStorage(error));
        }
      }
      return Ok(AdminProductDeleted(id: productId));
    },
    storageError: AdminDeleteProductStorage.new,
  );
}
