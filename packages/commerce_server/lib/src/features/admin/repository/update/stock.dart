import 'package:dust_dart/db.dart';

part 'stock.g.dart';

/// Aggregate variant-stock writes behind the protected merchant boundary.
@SqlxDao()
abstract final class AdminProductStockRepository {
  /// Binds stock mutations to [db].
  const factory AdminProductStockRepository(Executor db) =
      _$AdminProductStockRepository;

  /// Confirms that one active variant belongs to the routed product.
  @Query(r'''
SELECT count(*)
FROM product_variants
WHERE id = $1 AND product_id = $2 AND deleted_at IS NULL
''')
  Future<Result<int, SqlxError>> variantCount(
    String variantId,
    String productId,
  );

  /// Replaces merchant stock while database triggers own `updated_at`.
  @Query(r'''
UPDATE product_variants
SET inventory_quantity = $3,
    manage_inventory = $4
WHERE id = $1 AND product_id = $2 AND deleted_at IS NULL
''')
  Future<Result<ExecResult, SqlxError>> update(
    String variantId,
    String productId,
    int inventoryQuantity,
    int manageInventory,
  );
}
