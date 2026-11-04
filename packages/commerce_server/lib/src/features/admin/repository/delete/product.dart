import 'package:dust_dart/db.dart';

part 'product.g.dart';

/// Product retirement writes behind the protected merchant boundary.
@SqlxDao()
abstract final class AdminProductDeleteRepository {
  /// Binds product retirement statements to [db].
  const factory AdminProductDeleteRepository(Executor db) =
      _$AdminProductDeleteRepository;

  /// Retires one active product and lets its trigger advance `updated_at`.
  @Query(r'''
UPDATE products
SET deleted_at = strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
WHERE id = $1 AND deleted_at IS NULL
''')
  Future<Result<ExecResult, SqlxError>> product(String productId);

  /// Retires active variants so their unique SKUs can be reused.
  @Query(r'''
UPDATE product_variants
SET deleted_at = strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
WHERE product_id = $1 AND deleted_at IS NULL
''')
  Future<Result<ExecResult, SqlxError>> variants(String productId);

  /// Retires product images while leaving external files recoverable.
  @Query(r'''
UPDATE product_images
SET deleted_at = strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
WHERE product_id = $1 AND deleted_at IS NULL
''')
  Future<Result<ExecResult, SqlxError>> images(String productId);

  /// Retires values owned only by this product's exclusive options.
  @Query(r'''
UPDATE product_option_values
SET deleted_at = strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
WHERE deleted_at IS NULL AND option_id IN (
  SELECT link.product_option_id
  FROM product_product_options link
  JOIN product_options option ON option.id = link.product_option_id
  WHERE link.product_id = $1 AND option.is_exclusive = 1
)
''')
  Future<Result<ExecResult, SqlxError>> exclusiveOptionValues(String productId);

  /// Retires options created only for this product.
  @Query(r'''
UPDATE product_options
SET deleted_at = strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
WHERE deleted_at IS NULL AND is_exclusive = 1 AND id IN (
  SELECT product_option_id FROM product_product_options WHERE product_id = $1
)
''')
  Future<Result<ExecResult, SqlxError>> exclusiveOptions(String productId);

  /// Retires the selected values offered through this product's option links.
  @Query(r'''
UPDATE product_product_option_values
SET deleted_at = strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
WHERE deleted_at IS NULL AND product_product_option_id IN (
  SELECT id FROM product_product_options WHERE product_id = $1
)
''')
  Future<Result<ExecResult, SqlxError>> productOptionValues(String productId);

  /// Retires option membership without changing reusable global options.
  @Query(r'''
UPDATE product_product_options
SET deleted_at = strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
WHERE product_id = $1 AND deleted_at IS NULL
''')
  Future<Result<ExecResult, SqlxError>> productOptions(String productId);
}
