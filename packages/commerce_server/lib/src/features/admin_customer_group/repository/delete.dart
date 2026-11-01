import 'package:dust_dart/db.dart';

part 'delete.g.dart';

/// Direct SQLx persistence for retiring one customer-group graph.
@SqlxDao()
abstract final class AdminCustomerGroupDeleteRepository {
  /// Binds customer-group deletion statements to [db].
  const factory AdminCustomerGroupDeleteRepository(Executor db) =
      _$AdminCustomerGroupDeleteRepository;

  /// Soft-deletes one active group while retaining its audit history.
  @Query(r'''
UPDATE customer_groups
SET deleted_at = strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
WHERE id = $1 AND deleted_at IS NULL
''')
  Future<Result<ExecResult, SqlxError>> group(String id);

  /// Retires every active membership owned by the deleted group.
  @Query(r'''
UPDATE customer_group_customers
SET deleted_at = strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
WHERE customer_group_id = $1 AND deleted_at IS NULL
''')
  Future<Result<ExecResult, SqlxError>> memberships(String customerGroupId);
}
