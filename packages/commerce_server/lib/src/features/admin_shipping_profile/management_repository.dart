import 'package:commerce_server/src/features/admin_shipping_profile/model.dart';
import 'package:dust_dart/db.dart';

part 'management_repository.g.dart';

/// Direct SQLx persistence for shipping-profile settings management.
@SqlxDao()
abstract final class AdminShippingProfileManagementRepository {
  /// Binds settings operations to [db].
  const factory AdminShippingProfileManagementRepository(Executor db) =
      _$AdminShippingProfileManagementRepository;

  /// Reads one active direct response row.
  @Query(r'''
SELECT id, name, type, created_at, updated_at
FROM shipping_profile
WHERE id = $1 AND deleted_at IS NULL
''')
  Future<Result<AdminShippingProfileResponse?, SqlxError>> find(String id);

  /// Inserts normalized input unless an active case-insensitive name exists.
  @Query(r'''
INSERT INTO shipping_profile (id, name, type)
SELECT $1, trim($2), trim($3)
WHERE NOT EXISTS (
  SELECT 1 FROM shipping_profile
  WHERE lower(name) = lower(trim($2)) AND deleted_at IS NULL
)
RETURNING id, name, type, created_at, updated_at
''')
  Future<Result<AdminShippingProfileResponse?, SqlxError>> insert(
    String id,
    String name,
    String type,
  );

  /// Soft-deletes one active profile using a database-generated UTC instant.
  @Query(r'''
UPDATE shipping_profile
SET deleted_at = CURRENT_TIMESTAMP
WHERE id = $1 AND deleted_at IS NULL
''')
  Future<Result<ExecResult, SqlxError>> retire(String id);

  /// Retires active product links when their profile is retired.
  @Query(r'''
UPDATE product_shipping_profile
SET deleted_at = CURRENT_TIMESTAMP
WHERE shipping_profile_id = $1 AND deleted_at IS NULL
''')
  Future<Result<ExecResult, SqlxError>> retireProductLinks(String id);
}
