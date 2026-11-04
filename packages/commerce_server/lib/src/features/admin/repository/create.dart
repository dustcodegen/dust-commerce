import 'package:commerce_server/src/features/admin/model.dart';
import 'package:commerce_server/src/features/admin/product_type_model.dart';
import 'package:dust_dart/db.dart';

part 'create.g.dart';

/// Writes used by bootstrap and session issuance.
@SqlxDao()
abstract final class AdminCreateRepository {
  /// Binds the queries to [db].
  const factory AdminCreateRepository(Executor db) = _$AdminCreateRepository;

  /// Creates one active admin profile and returns only its public fields.
  @Query(r'''
INSERT INTO admin_users (id, email, first_name, last_name)
VALUES ($1, $2, $3, $4)
ON CONFLICT DO NOTHING
RETURNING id, email, first_name, last_name
''')
  Future<Result<AdminUserResponse?, SqlxError>> insertAdmin(
    String id,
    String email,
    String? firstName,
    String? lastName,
  );

  /// Creates the provider-independent identity for an admin actor.
  @Query(r'INSERT INTO auth_identity (id, app_metadata) VALUES ($1, $2)')
  Future<Result<ExecResult, SqlxError>> insertAuthIdentity(
    String id,
    String appMetadata,
  );

  /// Attaches the admin-specific email/password provider and Argon2id value.
  @Query(r'''
INSERT INTO provider_identity
  (id, entity_id, provider, auth_identity_id, provider_metadata)
VALUES ($1, $2, 'emailpass_admin', $3, $4)
''')
  Future<Result<ExecResult, SqlxError>> insertProviderIdentity(
    String id,
    String email,
    String authIdentityId,
    String providerMetadata,
  );

  /// Stores only an opaque token fingerprint with a bounded expiry.
  @Query(r'''
INSERT INTO auth_tokens (token_hash, auth_identity_id, expires_at)
VALUES ($1, $2, $3)
''')
  Future<Result<ExecResult, SqlxError>> insertToken(
    String tokenHash,
    String authIdentityId,
    String expiresAt,
  );
}

/// Product-type creation writes kept outside identity persistence.
@SqlxDao()
abstract final class AdminProductTypeCreateRepository {
  /// Binds product-type creation to [db].
  const factory AdminProductTypeCreateRepository(Executor db) =
      _$AdminProductTypeCreateRepository;

  /// Inserts one active value unless its normalized label is already owned.
  @Query(r'''
INSERT INTO product_types (id, value)
SELECT $1, trim($2)
WHERE NOT EXISTS (
  SELECT 1 FROM product_types
  WHERE lower(value) = lower(trim($2)) AND deleted_at IS NULL
)
RETURNING id, value, created_at, updated_at
''')
  Future<Result<AdminProductTypeResponse?, SqlxError>> insertProductType(
    String id,
    String value,
  );
}
