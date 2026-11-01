import 'package:commerce_server/src/features/collection/model.dart';
import 'package:dust_dart/db.dart';

part 'list.g.dart';

/// Public collection-list query.
@SqlxDao()
abstract final class ProductCollectionRepository {
  /// Binds the query to [db].
  const factory ProductCollectionRepository(Executor db) =
      _$ProductCollectionRepository;

  /// Active collections, optionally narrowed to one route handle.
  @Query(r'''
SELECT id, title, handle
FROM product_collections
WHERE deleted_at IS NULL AND (CAST($1 AS TEXT) IS NULL OR handle = $1)
ORDER BY title, id
LIMIT $2 OFFSET $3
''')
  Future<Result<List<ProductCollectionResponse>, SqlxError>> list(
    String? handle,
    int limit,
    int offset,
  );
}
