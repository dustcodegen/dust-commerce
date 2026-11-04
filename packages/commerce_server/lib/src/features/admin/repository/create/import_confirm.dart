import 'package:commerce_server/src/features/admin/product_import_model.dart';
import 'package:dust_dart/db.dart';

part 'import_confirm.g.dart';

/// Staged-import lifecycle and confirmation preflight queries.
@SqlxDao()
abstract final class AdminProductImportConfirmRepository {
  /// Binds confirmation reads and finalization to [db].
  const factory AdminProductImportConfirmRepository(Executor db) =
      _$AdminProductImportConfirmRepository;

  /// Reads only a staged import owned by the authenticated administrator.
  @Query(r'''
SELECT id, payload_json, status, expires_at
FROM product_imports
WHERE id = $1 AND admin_user_id = $2 AND deleted_at IS NULL
''')
  Future<Result<AdminProductImportRow?, SqlxError>> findImport(
    String id,
    String adminUserId,
  );

  /// Finds every product matched by the incoming id or handle.
  @Query(r'''
SELECT id, handle FROM products
WHERE deleted_at IS NULL
  AND (($1 <> '' AND id = $1) OR handle = $2)
ORDER BY id
''')
  Future<Result<List<AdminProductImportIdentityRow>, SqlxError>> findProducts(
    String id,
    String handle,
  );

  /// Reads one active variant by id.
  @Query(r'''
SELECT id, product_id, sku FROM product_variants
WHERE id = $1 AND deleted_at IS NULL
''')
  Future<Result<AdminProductImportVariantRow?, SqlxError>> findVariant(
    String id,
  );

  /// Reads an active SKU owner, excluding one variant being updated.
  @Query(r'''
SELECT id, product_id, sku FROM product_variants
WHERE sku = $1 AND deleted_at IS NULL AND ($2 = '' OR id <> $2)
''')
  Future<Result<AdminProductImportVariantRow?, SqlxError>> findSkuOwner(
    String sku,
    String excludedVariantId,
  );

  /// Confirms a reusable classification is active.
  @Query(r'''
SELECT count(*) FROM product_types
WHERE id = $1 AND deleted_at IS NULL
''')
  Future<Result<int, SqlxError>> activeTypeCount(String id);

  /// Confirms a curated collection is active.
  @Query(r'''
SELECT count(*) FROM product_collections
WHERE id = $1 AND deleted_at IS NULL
''')
  Future<Result<int, SqlxError>> activeCollectionCount(String id);

  /// Returns every currency configured by an active selling region.
  @Query(r'''
SELECT DISTINCT currency_code FROM regions
WHERE deleted_at IS NULL ORDER BY currency_code
''')
  Future<Result<List<AdminProductImportCurrencyRow>, SqlxError>>
      activeCurrencies();

  /// Consumes one still-pending import after its catalogue writes succeed.
  @Query(r'''
UPDATE product_imports SET status = 'completed'
WHERE id = $1 AND admin_user_id = $2 AND status = 'pending'
  AND deleted_at IS NULL
''')
  Future<Result<ExecResult, SqlxError>> complete(
    String id,
    String adminUserId,
  );

  /// Records expiry when an owner attempts to consume a stale import.
  @Query(r'''
UPDATE product_imports SET status = 'expired'
WHERE id = $1 AND admin_user_id = $2 AND status = 'pending'
  AND deleted_at IS NULL
''')
  Future<Result<ExecResult, SqlxError>> expire(
    String id,
    String adminUserId,
  );
}
