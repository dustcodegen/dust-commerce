import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin/model.dart';
import 'package:commerce_server/src/features/admin/repository/read/product.dart';
import 'package:commerce_server/src/features/admin/repository/update/stock.dart';
import 'package:commerce_server/src/infra/database.dart';
import 'package:commerce_server/src/infra/option.dart';
import 'package:dust_dart/db.dart';

/// Business reason a selected stock batch could not be applied.
enum AdminUpdateProductStockFailure {
  /// The selection is empty, duplicated, or contains invalid stock.
  invalid,

  /// A selected active variant does not belong to the routed product.
  notFound,

  /// The committed product could not be read back.
  unavailable,
}

/// Error crossing the Admin product-stock boundary.
sealed class AdminUpdateProductStockError {
  /// Creates one product-stock error.
  const AdminUpdateProductStockError();
}

/// A business rejection that is safe to expose to the handler.
final class AdminUpdateProductStockRejected
    extends AdminUpdateProductStockError {
  /// Creates one business rejection.
  const AdminUpdateProductStockRejected(this.failure);

  /// The stable business reason.
  final AdminUpdateProductStockFailure failure;
}

/// A storage failure retained for logging without exposing SQL details.
final class AdminUpdateProductStockStorage
    extends AdminUpdateProductStockError {
  /// Creates one storage failure.
  const AdminUpdateProductStockStorage(this.cause);

  /// The original SQLx failure.
  final SqlxError cause;
}

/// Atomically replaces aggregate stock for selected product variants.
Future<Result<AdminProductDetailResponse, AdminUpdateProductStockError>>
    updateAdminProductStock(
  CommerceDatabase database,
  String productId,
  AdminUpdateProductStock input,
) async {
  return transactionResult<AdminProductDetailResponse,
      AdminUpdateProductStockError>(
    database,
    (tx) async {
      final rows = input.variants;
      final ids = {for (final row in rows) row.id};
      if (rows.isEmpty || ids.length != rows.length) {
        return const Err(
          AdminUpdateProductStockRejected(
            AdminUpdateProductStockFailure.invalid,
          ),
        );
      }
      if (rows.any((row) => row.id.isEmpty || row.inventoryQuantity < 0)) {
        return const Err(
          AdminUpdateProductStockRejected(
            AdminUpdateProductStockFailure.invalid,
          ),
        );
      }

      final stock = AdminProductStockRepository(tx);
      for (final row in rows) {
        final found = await stock.variantCount(row.id, productId);
        if (found case Err(:final error)) {
          return Err(AdminUpdateProductStockStorage(error));
        }
        if ((found as Ok<int, SqlxError>).value != 1) {
          return const Err(
            AdminUpdateProductStockRejected(
              AdminUpdateProductStockFailure.notFound,
            ),
          );
        }
      }
      for (final row in rows) {
        final updated = await stock.update(
          row.id,
          productId,
          row.inventoryQuantity,
          row.manageInventory ? 1 : 0,
        );
        if (updated case Err(:final error)) {
          return Err(AdminUpdateProductStockStorage(error));
        }
      }

      final refreshed =
          await AdminProductReadRepository(tx).findById(productId);
      if (refreshed case Err(:final error)) {
        return Err(AdminUpdateProductStockStorage(error));
      }
      return switch (optionOf(
        (refreshed as Ok<AdminProductDetailResponse?, SqlxError>).value,
      )) {
        Some(:final value) => Ok(value),
        None() => const Err(AdminUpdateProductStockRejected(
            AdminUpdateProductStockFailure.unavailable,
          )),
      };
    },
    storageError: AdminUpdateProductStockStorage.new,
  );
}
