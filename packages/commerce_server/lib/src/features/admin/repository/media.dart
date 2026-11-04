import 'package:dust_dart/db.dart';

part 'media.g.dart';

/// Reference checks that keep attached product files from being deleted.
@SqlxDao()
abstract final class AdminMediaRepository {
  /// Binds media reference reads to [db].
  const factory AdminMediaRepository(Executor db) = _$AdminMediaRepository;

  /// Counts active product-image rows that still point at [url].
  @Query(r'''
SELECT count(*)
FROM product_images
WHERE url = $1 AND deleted_at IS NULL
''')
  Future<Result<int, SqlxError>> countReferences(String url);
}
