import 'package:dust_dart/db.dart';

part 'update_repository.g.dart';

/// Direct SQLx persistence for merchant customer profile replacement.
@SqlxDao()
abstract final class AdminCustomerUpdateRepository {
  /// Binds customer updates to [db].
  const factory AdminCustomerUpdateRepository(Executor db) =
      _$AdminCustomerUpdateRepository;

  /// Replaces contact fields while the account-email guard still matches.
  @Query(r'''
UPDATE customers
SET email = CASE WHEN has_account = 1 THEN email ELSE CAST($2 AS TEXT) END,
    company_name = $3,
    first_name = $4,
    last_name = $5,
    phone = $6
WHERE id = $1
  AND deleted_at IS NULL
  AND (
    (has_account = 0 AND CAST($2 AS TEXT) IS NOT NULL AND NOT EXISTS (
      SELECT 1
      FROM customers conflict
      WHERE conflict.id <> customers.id
        AND conflict.deleted_at IS NULL
        AND conflict.has_account = 0
        AND lower(conflict.email) = lower(CAST($2 AS TEXT))
    )) OR
    (has_account = 1 AND (CAST($2 AS TEXT) IS NULL OR email = CAST($2 AS TEXT)))
  )
''')
  Future<Result<ExecResult, SqlxError>> update(
    String id,
    String? email,
    String? companyName,
    String? firstName,
    String? lastName,
    String? phone,
  );
}
