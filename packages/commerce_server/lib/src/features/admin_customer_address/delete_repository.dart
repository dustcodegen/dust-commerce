import 'package:dust_dart/db.dart';

part 'delete_repository.g.dart';

/// Direct SQLx persistence for one customer-owned address deletion.
@SqlxDao()
abstract final class AdminCustomerAddressDeleteRepository {
  /// Binds the deletion statement to [db].
  const factory AdminCustomerAddressDeleteRepository(Executor db) =
      _$AdminCustomerAddressDeleteRepository;

  /// Soft-deletes only an active address owned by an active customer.
  @Query(r'''
UPDATE customer_addresses
SET deleted_at = strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
WHERE id = $1 AND customer_id = $2 AND deleted_at IS NULL
  AND EXISTS (
    SELECT 1 FROM customers WHERE id = $2 AND deleted_at IS NULL
  )
''')
  Future<Result<ExecResult, SqlxError>> delete(
    String addressId,
    String customerId,
  );
}
