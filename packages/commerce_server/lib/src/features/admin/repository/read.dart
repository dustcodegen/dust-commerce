import 'package:commerce_server/src/features/admin/model.dart';
import 'package:commerce_server/src/features/admin/product_type_model.dart';
import 'package:dust_dart/db.dart';

export 'read/product.dart';

part 'read.g.dart';

/// Admin credential and session lookups.
@SqlxDao()
abstract final class AdminReadRepository {
  /// Binds the queries to [db].
  const factory AdminReadRepository(Executor db) = _$AdminReadRepository;

  /// Resolves an active admin credential without exposing provider metadata.
  @Query(r'''
SELECT a.id AS auth_identity_id,
       coalesce(CAST(json_extract(p.provider_metadata, '$.password') AS TEXT),
                '') AS password_hash
FROM provider_identity p
JOIN auth_identity a ON a.id = p.auth_identity_id
JOIN admin_users u
  ON u.id = CAST(json_extract(a.app_metadata, '$.admin_user_id') AS TEXT)
WHERE p.provider = 'emailpass_admin'
  AND LOWER(p.entity_id) = LOWER($1)
  AND p.deleted_at IS NULL
  AND a.deleted_at IS NULL
  AND u.deleted_at IS NULL
  AND u.status = 'active'
''')
  Future<Result<AdminPasswordCredential?, SqlxError>> adminByEmail(
      String email);

  /// Resolves an unexpired token fingerprint only to an active admin actor.
  @Query(r'''
SELECT u.id, u.email, u.first_name, u.last_name
FROM auth_tokens t
JOIN auth_identity a ON a.id = t.auth_identity_id
JOIN admin_users u
  ON u.id = CAST(json_extract(a.app_metadata, '$.admin_user_id') AS TEXT)
WHERE t.token_hash = $1
  AND t.expires_at > $2
  AND a.deleted_at IS NULL
  AND u.deleted_at IS NULL
  AND u.status = 'active'
''')
  Future<Result<AdminUserResponse?, SqlxError>> adminForToken(
    String tokenHash,
    String now,
  );
}

/// Product-type detail reads kept separate from list discovery.
@SqlxDao()
abstract final class AdminProductTypeReadRepository {
  /// Binds product-type reads to [db].
  const factory AdminProductTypeReadRepository(Executor db) =
      _$AdminProductTypeReadRepository;

  /// Reads one active direct response row by stable identifier.
  @Query(r'''
SELECT id, value, created_at, updated_at
FROM product_types
WHERE id = $1 AND deleted_at IS NULL
''')
  Future<Result<AdminProductTypeResponse?, SqlxError>> findProductType(
    String id,
  );
}
