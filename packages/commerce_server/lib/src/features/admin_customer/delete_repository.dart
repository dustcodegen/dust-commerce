import 'package:commerce_server/src/features/admin_customer/delete_model.dart';
import 'package:dust_dart/db.dart';

part 'delete_repository.g.dart';

/// Direct SQLx persistence for customer and account removal.
@SqlxDao()
abstract final class AdminCustomerDeleteRepository {
  /// Binds customer deletion statements to [db].
  const factory AdminCustomerDeleteRepository(Executor db) =
      _$AdminCustomerDeleteRepository;

  /// Reads the active profile and its auth-identity ownership boundary.
  @Query(r'''
WITH active_identity AS (
  SELECT id, app_metadata
  FROM auth_identity
  WHERE deleted_at IS NULL
    AND json_extract(app_metadata, '$.customer_id') = $1
)
SELECT customer.has_account,
       (SELECT min(id) FROM active_identity) AS auth_identity_id,
       (SELECT count(*) FROM active_identity) AS auth_identity_count,
       CASE WHEN EXISTS (
         SELECT 1 FROM active_identity, json_each(active_identity.app_metadata)
         WHERE json_each.key <> 'customer_id' AND json_each.value IS NOT NULL
       ) THEN 1 ELSE 0 END AS has_other_actor
FROM customers customer
WHERE customer.id = $1 AND customer.deleted_at IS NULL
''')
  Future<Result<AdminCustomerDeleteContext?, SqlxError>> find(String id);

  /// Soft-deletes one active customer while preserving historical references.
  @Query(r'''
UPDATE customers
SET deleted_at = strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
WHERE id = $1 AND deleted_at IS NULL
''')
  Future<Result<ExecResult, SqlxError>> customer(String id);

  /// Soft-deletes reusable addresses with the owning customer.
  @Query(r'''
UPDATE customer_addresses
SET deleted_at = strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
WHERE customer_id = $1 AND deleted_at IS NULL
''')
  Future<Result<ExecResult, SqlxError>> addresses(String customerId);

  /// Removes only the customer actor from a shared authentication identity.
  @Query(r'''
UPDATE auth_identity
SET app_metadata = json_remove(app_metadata, '$.customer_id')
WHERE id = $1 AND deleted_at IS NULL
''')
  Future<Result<ExecResult, SqlxError>> detachCustomer(String authIdentityId);

  /// Revokes every live session owned only by the removed customer.
  @Query(r'DELETE FROM auth_tokens WHERE auth_identity_id = $1')
  Future<Result<ExecResult, SqlxError>> tokens(String authIdentityId);

  /// Removes any pending or completed email-verification capability.
  @Query(r'DELETE FROM email_verifications WHERE auth_identity_id = $1')
  Future<Result<ExecResult, SqlxError>> verification(String authIdentityId);

  /// Retires provider credentials owned only by this customer actor.
  @Query(r'''
UPDATE provider_identity
SET deleted_at = strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
WHERE auth_identity_id = $1 AND deleted_at IS NULL
''')
  Future<Result<ExecResult, SqlxError>> providers(String authIdentityId);

  /// Retires an authentication identity after its final actor is removed.
  @Query(r'''
UPDATE auth_identity
SET deleted_at = strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
WHERE id = $1 AND deleted_at IS NULL
''')
  Future<Result<ExecResult, SqlxError>> identity(String authIdentityId);
}
