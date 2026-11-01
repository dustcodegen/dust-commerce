import 'package:commerce_server/src/features/category/model.dart';
import 'package:dust_dart/db.dart';

part 'list.g.dart';

/// Public category-list query.
@SqlxDao()
abstract final class ProductCategoryRepository {
  /// Binds the query to [db].
  const factory ProductCategoryRepository(Executor db) =
      _$ProductCategoryRepository;

  /// Active categories, optionally narrowed to one full route handle.
  @Query(r'''
SELECT id, name, description, handle, parent_category_id
FROM product_categories
WHERE deleted_at IS NULL AND is_active = 1
  AND (CAST($1 AS TEXT) IS NULL OR handle = $1)
ORDER BY rank, name, id
LIMIT $2 OFFSET $3
''')
  Future<Result<List<ProductCategoryResponse>, SqlxError>> list(
    String? handle,
    int limit,
    int offset,
  );
}
