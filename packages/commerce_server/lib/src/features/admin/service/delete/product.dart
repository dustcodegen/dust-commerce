import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin/repository/delete/product.dart';
import 'package:commerce_server/src/infra/database.dart';
import 'package:dust_dart/db.dart';

/// Business reason an active product could not be retired.
enum AdminDeleteProductFailure {
  /// No active product owns the requested identifier.
  notFound,
}

/// Soft-deletes one product graph while retaining historical rows.
Future<
        Result<Result<AdminProductDeleted, AdminDeleteProductFailure>,
            SqlxError>>
    deleteAdminProduct(CommerceDatabase database, String productId) =>
        database.transaction((tx) async {
          final deletes = AdminProductDeleteRepository(tx);
          final product = await deletes.product(productId);
          if (product case Err(:final error)) return Err(error);
          if ((product as Ok<ExecResult, SqlxError>).value.rowsAffected == 0) {
            return const Ok(Err(AdminDeleteProductFailure.notFound));
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
            if (result case Err(:final error)) return Err(error);
          }
          return Ok(Ok(AdminProductDeleted(id: productId)));
        });
