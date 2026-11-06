import 'package:dust_dart/db.dart';

part 'media.g.dart';

/// Private SQLx projection used by staged-media cleanup.
@Derive([FromRow()])
final class AdminMediaReference {
  /// Creates one active public media reference.
  const AdminMediaReference({required this.url});

  /// Public URL retained by an active product image.
  final String url;
}

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

  /// Lists every active public URL so staged files can be reclaimed safely.
  @Query(r'''
SELECT DISTINCT url
FROM product_images
WHERE deleted_at IS NULL
''')
  Future<Result<List<AdminMediaReference>, SqlxError>> activeUrls();
}
