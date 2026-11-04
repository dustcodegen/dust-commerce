import 'package:dust_dart/db.dart';

part 'delete.g.dart';

/// Admin session revocation.
@SqlxDao()
abstract final class AdminDeleteRepository {
  /// Binds the query to [db].
  const factory AdminDeleteRepository(Executor db) = _$AdminDeleteRepository;

  /// Revokes one bearer token by its fingerprint.
  @Query(r'DELETE FROM auth_tokens WHERE token_hash = $1')
  Future<Result<ExecResult, SqlxError>> revokeToken(String tokenHash);
}

/// Product-type retirement writes kept outside session revocation.
@SqlxDao()
abstract final class AdminProductTypeDeleteRepository {
  /// Binds product-type retirement to [db].
  const factory AdminProductTypeDeleteRepository(Executor db) =
      _$AdminProductTypeDeleteRepository;

  /// Soft-deletes one active type using a database-generated UTC instant.
  @Query(r'''
UPDATE product_types
SET deleted_at = strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
WHERE id = $1 AND deleted_at IS NULL
''')
  Future<Result<ExecResult, SqlxError>> retireProductType(String id);
}
