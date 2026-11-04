import 'package:dust_dart/db.dart';

part 'update.g.dart';

/// Direct SQLx persistence for customer-group name replacement.
@SqlxDao()
abstract final class AdminCustomerGroupUpdateRepository {
  /// Binds customer-group updates to [db].
  const factory AdminCustomerGroupUpdateRepository(Executor db) =
      _$AdminCustomerGroupUpdateRepository;

  /// Replaces the name only while the group remains active.
  @Query(r'''
UPDATE customer_groups
SET name = $2
WHERE id = $1 AND deleted_at IS NULL
''')
  Future<Result<ExecResult, SqlxError>> update(String id, String name);
}
