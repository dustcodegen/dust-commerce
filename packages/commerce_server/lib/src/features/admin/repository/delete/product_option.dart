import 'package:dust_dart/db.dart';

part 'product_option.g.dart';

/// Product-option retirement queries behind the protected merchant route.
@SqlxDao()
abstract final class AdminProductOptionDeleteRepository {
  /// Binds product-option retirement to [db].
  const factory AdminProductOptionDeleteRepository(Executor db) =
      _$AdminProductOptionDeleteRepository;

  /// Counts active products that still expose this option.
  @Query(r'''
SELECT count(*)
FROM product_product_options link
JOIN products product ON product.id = link.product_id
WHERE link.product_option_id = $1
  AND link.deleted_at IS NULL
  AND product.deleted_at IS NULL
''')
  Future<Result<int, SqlxError>> linkedProductCount(String optionId);

  /// Retires the option values only after all product links are gone.
  @Query(r'''
UPDATE product_option_values
SET deleted_at = strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
WHERE option_id = $1 AND deleted_at IS NULL
''')
  Future<Result<ExecResult, SqlxError>> retireValues(String optionId);

  /// Retires one option while retaining its audit history.
  @Query(r'''
UPDATE product_options
SET deleted_at = strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
WHERE id = $1 AND deleted_at IS NULL
''')
  Future<Result<ExecResult, SqlxError>> retireOption(String optionId);
}
