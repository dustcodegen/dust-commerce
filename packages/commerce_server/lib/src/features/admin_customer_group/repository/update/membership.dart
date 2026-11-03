import 'package:dust_dart/db.dart';

part 'membership.g.dart';

/// Direct SQLx reads and writes for one customer-group membership batch.
@SqlxDao()
abstract final class AdminCustomerGroupMembershipRepository {
  /// Binds membership operations to [db].
  const factory AdminCustomerGroupMembershipRepository(Executor db) =
      _$AdminCustomerGroupMembershipRepository;

  /// Confirms that the route owns one active customer group.
  @Query(r'''
SELECT count(*)
FROM customer_groups
WHERE id = $1 AND deleted_at IS NULL
''')
  Future<Result<int, SqlxError>> activeGroupCount(String groupId);

  /// Counts active customers from the distinct validated request ids.
  @Query(r'''
SELECT count(*)
FROM customers
WHERE deleted_at IS NULL
  AND id IN (
    SELECT value FROM jsonb_array_elements_text($1::jsonb) AS item(value)
  )
''')
  Future<Result<int, SqlxError>> activeCustomerCount(String customerIdsJson);

  /// Soft-deletes matching active memberships without changing customers.
  @Query(r'''
UPDATE customer_group_customers
SET deleted_at = strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
WHERE customer_group_id = $1
  AND deleted_at IS NULL
  AND customer_id IN (
    SELECT value FROM jsonb_array_elements_text($2::jsonb) AS item(value)
  )
''')
  Future<Result<ExecResult, SqlxError>> remove(
    String groupId,
    String customerIdsJson,
  );

  /// Adds only missing active links while retaining old membership history.
  @Query(r'''
INSERT INTO customer_group_customers
  (id, customer_group_id, customer_id, created_by)
SELECT incoming.value ->> 'id',
       $1,
       incoming.value ->> 'customer_id',
       $2
FROM jsonb_array_elements($3::jsonb) incoming
WHERE NOT EXISTS (
  SELECT 1
  FROM customer_group_customers membership
  WHERE membership.customer_group_id = $1
    AND membership.customer_id = incoming.value ->> 'customer_id'
    AND membership.deleted_at IS NULL
)
''')
  Future<Result<ExecResult, SqlxError>> add(
    String groupId,
    String createdBy,
    String membershipsJson,
  );
}
