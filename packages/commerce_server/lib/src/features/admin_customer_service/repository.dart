import 'package:commerce_server/src/features/admin_customer_service/model.dart';
import 'package:dust_dart/db.dart';

part 'repository.g.dart';

/// Protected direct-SQLx persistence for the merchant support inbox.
@SqlxDao()
abstract final class AdminCustomerServiceRepository {
  /// Binds support request operations to [db].
  const factory AdminCustomerServiceRepository(Executor db) =
      _$AdminCustomerServiceRepository;

  /// Lists only fields consumed by the isolated Admin contract.
  @Query(r'''
SELECT id, customer_id, name, email, subject, message, order_reference,
       status, resolved_at, created_at, updated_at
FROM customer_service_requests
WHERE ($1 = '' OR lower(id) LIKE '%' || lower($1) || '%'
       OR lower(name) LIKE '%' || lower($1) || '%'
       OR lower(email) LIKE '%' || lower($1) || '%'
       OR lower(subject) LIKE '%' || lower($1) || '%'
       OR lower(coalesce(order_reference, '')) LIKE '%' || lower($1) || '%')
  AND ($2 = '' OR instr(',' || $2 || ',', ',' || status || ',') > 0)
ORDER BY
  CASE WHEN $3 = 'created_at' THEN created_at END ASC,
  CASE WHEN $3 = '-created_at' THEN created_at END DESC,
  CASE WHEN $3 = 'updated_at' THEN updated_at END ASC,
  CASE WHEN $3 = '-updated_at' THEN updated_at END DESC,
  created_at DESC,
  id DESC
LIMIT $4 OFFSET $5
''')
  Future<Result<List<AdminCustomerServiceResponse>, SqlxError>> list(
    String query,
    String statuses,
    String order,
    int limit,
    int offset,
  );

  /// Counts rows through the same search and status boundary.
  @Query(r'''
SELECT count(*)
FROM customer_service_requests
WHERE ($1 = '' OR lower(id) LIKE '%' || lower($1) || '%'
       OR lower(name) LIKE '%' || lower($1) || '%'
       OR lower(email) LIKE '%' || lower($1) || '%'
       OR lower(subject) LIKE '%' || lower($1) || '%'
       OR lower(coalesce(order_reference, '')) LIKE '%' || lower($1) || '%')
  AND ($2 = '' OR instr(',' || $2 || ',', ',' || status || ',') > 0)
''')
  Future<Result<int, SqlxError>> count(String query, String statuses);

  /// Reads one request after creation or lifecycle mutation.
  @Query(r'''
SELECT id, customer_id, name, email, subject, message, order_reference,
       status, resolved_at, created_at, updated_at
FROM customer_service_requests
WHERE id = $1
''')
  Future<Result<AdminCustomerServiceResponse?, SqlxError>> find(String id);

  /// Replaces lifecycle and lets PostgreSQL own resolution and update instants.
  @Query(r'''
UPDATE customer_service_requests
SET status = $2,
    resolved_at = CASE
      WHEN $2 = 'resolved' THEN coalesce(
        resolved_at, strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
      )
      ELSE NULL
    END
WHERE id = $1
''')
  Future<Result<ExecResult, SqlxError>> updateStatus(String id, String status);
}
