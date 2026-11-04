import 'package:dust_dart/db.dart';

part 'update.g.dart';

/// Product writes kept separate from merchant reads and auth persistence.
@SqlxDao()
abstract final class AdminProductUpdateRepository {
  /// Binds product mutations to [db].
  const factory AdminProductUpdateRepository(Executor db) =
      _$AdminProductUpdateRepository;

  /// Replaces supported general fields when no active product owns [handle].
  ///
  /// The single statement makes handle conflict detection race-safe under
  /// SQLite's serialized writer lock. Database triggers own `updated_at`.
  @Query(r'''
UPDATE products
SET title = trim($2),
    handle = $3,
    subtitle = nullif(trim($4), ''),
    material = nullif(trim($5), ''),
    description = nullif(trim($6), ''),
    discountable = $7,
    status = $8
WHERE id = $1
  AND deleted_at IS NULL
  AND NOT EXISTS (
    SELECT 1
    FROM products other
    WHERE other.handle = $3
      AND other.id <> $1
      AND other.deleted_at IS NULL
  )
''')
  Future<Result<ExecResult, SqlxError>> updateGeneral(
    String id,
    String title,
    String handle,
    String? subtitle,
    String? material,
    String? description,
    int discountable,
    String status,
  );

  /// Replaces only the product type when the requested type remains active.
  @Query(r'''
UPDATE products
SET type_id = $2
WHERE id = $1 AND deleted_at IS NULL
  AND (CAST($2 AS TEXT) IS NULL OR EXISTS (
    SELECT 1 FROM product_types
    WHERE id = $2 AND deleted_at IS NULL
  ))
''')
  Future<Result<ExecResult, SqlxError>> updateOrganization(
    String productId,
    String? typeId,
  );

  /// Returns the largest rank, including history rows kept after removal.
  @Query(r'''
SELECT coalesce(max(rank), -1)
FROM product_images
WHERE product_id = $1
''')
  Future<Result<int, SqlxError>> maxImageRank(String productId);

  /// Moves every old rank out of the compact active range before replacement.
  @Query(r'''
UPDATE product_images
SET rank = rank + $2
WHERE product_id = $1
''')
  Future<Result<ExecResult, SqlxError>> shiftImageRanks(
    String productId,
    int offset,
  );

  /// Retains one existing image at its requested compact rank.
  @Query(r'''
UPDATE product_images
SET rank = $3
WHERE id = $1 AND product_id = $2 AND deleted_at IS NULL
''')
  Future<Result<ExecResult, SqlxError>> rankImage(
    String imageId,
    String productId,
    int rank,
  );

  /// Attaches one staged upload at its requested compact rank.
  @Query(r'''
INSERT INTO product_images (id, product_id, url, rank)
VALUES ($1, $2, $3, $4)
''')
  Future<Result<ExecResult, SqlxError>> insertImage(
    String id,
    String productId,
    String url,
    int rank,
  );

  /// Soft-deletes old active rows not returned to the compact rank range.
  @Query(r'''
UPDATE product_images
SET deleted_at = strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
WHERE product_id = $1 AND deleted_at IS NULL AND rank >= $2
''')
  Future<Result<ExecResult, SqlxError>> deleteShiftedImages(
    String productId,
    int offset,
  );

  /// Replaces the product thumbnail from the same transaction as its gallery.
  @Query(r'''
UPDATE products
SET thumbnail = $2
WHERE id = $1 AND deleted_at IS NULL
''')
  Future<Result<ExecResult, SqlxError>> updateThumbnail(
    String productId,
    String? thumbnail,
  );
}

/// Product-type replacement writes behind the protected settings route.
@SqlxDao()
abstract final class AdminProductTypeUpdateRepository {
  /// Binds product-type replacement to [db].
  const factory AdminProductTypeUpdateRepository(Executor db) =
      _$AdminProductTypeUpdateRepository;

  /// Renames one active type unless another active type owns the value.
  @Query(r'''
UPDATE product_types
SET value = trim($2)
WHERE id = $1 AND deleted_at IS NULL
  AND NOT EXISTS (
    SELECT 1 FROM product_types sibling
    WHERE lower(sibling.value) = lower(trim($2))
      AND sibling.id <> $1 AND sibling.deleted_at IS NULL
  )
''')
  Future<Result<ExecResult, SqlxError>> updateProductType(
    String id,
    String value,
  );
}
