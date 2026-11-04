import 'package:dust_dart/db.dart';

part 'image_variants.g.dart';

/// Image-to-variant association reads and writes for one admin batch.
@SqlxDao()
abstract final class AdminProductImageVariantRepository {
  /// Binds association operations to [db].
  const factory AdminProductImageVariantRepository(Executor db) =
      _$AdminProductImageVariantRepository;

  /// Returns the active product that owns [imageId].
  @Query(r'''
SELECT product_id
FROM product_images
WHERE id = $1 AND deleted_at IS NULL
''')
  Future<Result<String?, SqlxError>> imageProduct(String imageId);

  /// Returns the active product that owns [variantId].
  @Query(r'''
SELECT product_id
FROM product_variants
WHERE id = $1 AND deleted_at IS NULL
''')
  Future<Result<String?, SqlxError>> variantProduct(String variantId);

  /// Adds one association idempotently.
  @Query(r'''
INSERT INTO product_image_variants (image_id, variant_id)
VALUES ($1, $2)
ON CONFLICT (image_id, variant_id) DO NOTHING
''')
  Future<Result<ExecResult, SqlxError>> add(String imageId, String variantId);

  /// Removes one association idempotently.
  @Query(r'''
DELETE FROM product_image_variants
WHERE image_id = $1 AND variant_id = $2
''')
  Future<Result<ExecResult, SqlxError>> remove(
    String imageId,
    String variantId,
  );

  /// Removes associations owned by images leaving the active gallery.
  @Query(r'''
DELETE FROM product_image_variants
WHERE image_id IN (
  SELECT id
  FROM product_images
  WHERE product_id = $1 AND deleted_at IS NULL AND rank >= $2
)
''')
  Future<Result<ExecResult, SqlxError>> removeForShiftedImages(
    String productId,
    int minimumRank,
  );
}
