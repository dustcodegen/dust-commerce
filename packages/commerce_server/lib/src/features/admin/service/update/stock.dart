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

/// Atomically replaces aggregate stock for selected product variants.
Future<
    Result<Result<AdminProductDetailResponse, AdminUpdateProductStockFailure>,
        SqlxError>> updateAdminProductStock(
  CommerceDatabase database,
  String productId,
  AdminUpdateProductStock input,
) =>
    database.transaction((tx) async {
      final rows = input.variants;
      final ids = {for (final row in rows) row.id};
      if (rows.isEmpty || ids.length != rows.length) {
        return const Ok(Err(AdminUpdateProductStockFailure.invalid));
      }
      if (rows.any((row) => row.id.isEmpty || row.inventoryQuantity < 0)) {
        return const Ok(Err(AdminUpdateProductStockFailure.invalid));
      }

      final stock = AdminProductStockRepository(tx);
      for (final row in rows) {
        final found = await stock.variantCount(row.id, productId);
        if (found case Err(:final error)) return Err(error);
        if ((found as Ok<int, SqlxError>).value != 1) {
          return const Ok(Err(AdminUpdateProductStockFailure.notFound));
        }
      }
      for (final row in rows) {
        final updated = await stock.update(
          row.id,
          productId,
          row.inventoryQuantity,
          row.manageInventory ? 1 : 0,
        );
        if (updated case Err(:final error)) return Err(error);
      }

      final refreshed =
          await AdminProductReadRepository(tx).findById(productId);
      if (refreshed case Err(:final error)) return Err(error);
      return switch (optionOf(
        (refreshed as Ok<AdminProductDetailResponse?, SqlxError>).value,
      )) {
        Some(:final value) => Ok(Ok(value)),
        None() => const Ok(Err(AdminUpdateProductStockFailure.unavailable)),
      };
    });
