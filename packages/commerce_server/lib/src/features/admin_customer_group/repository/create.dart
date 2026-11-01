import 'package:commerce_server/src/features/admin_customer_group/list_response.dart';
import 'package:dust_dart/db.dart';

part 'create.g.dart';

/// Direct SQLx persistence for merchant-created customer groups.
@SqlxDao()
abstract final class AdminCustomerGroupCreateRepository {
  /// Binds customer-group creation to [db].
  const factory AdminCustomerGroupCreateRepository(Executor db) =
      _$AdminCustomerGroupCreateRepository;

  /// Inserts one group and returns only the explicit Admin response columns.
  @Query(r'''
INSERT INTO customer_groups (id, name, created_by, metadata)
SELECT $1, $2, $3, $4
WHERE NOT EXISTS (
  SELECT 1 FROM customer_groups
  WHERE name = $2 AND deleted_at IS NULL
)
RETURNING id,
          name,
          '[]' AS customers_json,
          created_at,
          updated_at
''')
  Future<Result<AdminCustomerGroupResponse?, SqlxError>> insert(
    String id,
    String name,
    String createdBy,
    String? metadata,
  );
}
