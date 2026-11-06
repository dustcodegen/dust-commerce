import 'package:dust_dart/db.dart';

part 'delete_repository.g.dart';

/// Soft-deletion writes for merchant promotions.
@SqlxDao()
abstract final class AdminPromotionDeleteRepository {
  /// Binds retirement to [db].
  const factory AdminPromotionDeleteRepository(Executor db) =
      _$AdminPromotionDeleteRepository;

  /// Retires one active promotion and lets PostgreSQL own the timestamp.
  @Query(r'''
UPDATE promotions
SET deleted_at = CURRENT_TIMESTAMP
WHERE id = $1 AND deleted_at IS NULL
''')
  Future<Result<ExecResult, SqlxError>> retire(String id);
}
