import 'package:dust_dart/db.dart';

part 'delete.g.dart';

/// Session revocation.
@SqlxDao()
abstract final class AccountDeleteRepository {
  /// Binds the query to [db].
  const factory AccountDeleteRepository(Executor db) =
      _$AccountDeleteRepository;

  /// Revokes one bearer token by its fingerprint.
  @Query(r'DELETE FROM auth_tokens WHERE token_hash = $1')
  Future<Result<ExecResult, SqlxError>> revokeToken(String tokenHash);

  /// Revokes every session issued to one authentication identity.
  @Query(r'DELETE FROM auth_tokens WHERE auth_identity_id = $1')
  Future<Result<ExecResult, SqlxError>> revokeIdentityTokens(
    String authIdentityId,
  );

  /// Soft-deletes one address only when the customer owns it.
  @Query(r'''
UPDATE customer_addresses
SET deleted_at = strftime('%Y-%m-%dT%H:%M:%fZ', 'now'),
    is_default_shipping = 0,
    is_default_billing = 0
WHERE id = $1 AND customer_id = $2 AND deleted_at IS NULL
''')
  Future<Result<ExecResult, SqlxError>> deleteAddress(
    String id,
    String customerId,
  );
}
