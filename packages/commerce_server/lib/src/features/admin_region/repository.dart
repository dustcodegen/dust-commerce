import 'package:commerce_server/src/features/admin_region/model.dart';
import 'package:dust_dart/db.dart';

part 'repository.g.dart';

/// Read-only selling-region discovery used by Admin order filters.
@SqlxDao()
abstract final class AdminRegionRepository {
  /// Binds region list queries to [db].
  const factory AdminRegionRepository(Executor db) = _$AdminRegionRepository;

  /// Counts the same active region search result.
  @Query(r'''
SELECT count(*)
FROM regions
WHERE deleted_at IS NULL
  AND ($1 = '' OR lower(name) LIKE '%' || lower($1) || '%')
''')
  Future<Result<int, SqlxError>> count(String query);

  /// Lists active region choices in stable display order.
  @Query(r'''
SELECT id, name
FROM regions
WHERE deleted_at IS NULL
  AND ($1 = '' OR lower(name) LIKE '%' || lower($1) || '%')
ORDER BY lower(name), id
LIMIT $2 OFFSET $3
''')
  Future<Result<List<AdminRegionResponse>, SqlxError>> list(
    String query,
    int limit,
    int offset,
  );
}
