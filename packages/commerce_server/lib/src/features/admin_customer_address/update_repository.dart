import 'package:dust_dart/db.dart';

part 'update_repository.g.dart';

/// Direct SQLx persistence for partial customer-address updates.
@SqlxDao()
abstract final class AdminCustomerAddressUpdateRepository {
  /// Binds the update statement to [db].
  const factory AdminCustomerAddressUpdateRepository(Executor db) =
      _$AdminCustomerAddressUpdateRepository;

  /// Applies only present JSON fields to an active, customer-owned address.
  @Query(r'''
UPDATE customer_addresses
SET address_name = CASE WHEN json_type($3, '$.address_name') IS NULL
      THEN address_name ELSE json_extract($3, '$.address_name') END,
    first_name = CASE WHEN json_type($3, '$.first_name') IS NULL
      THEN first_name ELSE json_extract($3, '$.first_name') END,
    last_name = CASE WHEN json_type($3, '$.last_name') IS NULL
      THEN last_name ELSE json_extract($3, '$.last_name') END,
    company = CASE WHEN json_type($3, '$.company') IS NULL
      THEN company ELSE json_extract($3, '$.company') END,
    phone = CASE WHEN json_type($3, '$.phone') IS NULL
      THEN phone ELSE json_extract($3, '$.phone') END,
    address_1 = CASE WHEN json_type($3, '$.address_1') IS NULL
      THEN address_1 ELSE json_extract($3, '$.address_1') END,
    address_2 = CASE WHEN json_type($3, '$.address_2') IS NULL
      THEN address_2 ELSE json_extract($3, '$.address_2') END,
    city = CASE WHEN json_type($3, '$.city') IS NULL
      THEN city ELSE json_extract($3, '$.city') END,
    country_code = CASE WHEN json_type($3, '$.country_code') IS NULL
      THEN country_code ELSE json_extract($3, '$.country_code') END,
    province = CASE WHEN json_type($3, '$.province') IS NULL
      THEN province ELSE json_extract($3, '$.province') END,
    postal_code = CASE WHEN json_type($3, '$.postal_code') IS NULL
      THEN postal_code ELSE json_extract($3, '$.postal_code') END,
    is_default_shipping = CASE
      WHEN json_type($3, '$.is_default_shipping') IS NULL
      THEN is_default_shipping
      ELSE (json_extract($3, '$.is_default_shipping')::boolean)::integer END,
    is_default_billing = CASE
      WHEN json_type($3, '$.is_default_billing') IS NULL
      THEN is_default_billing
      ELSE (json_extract($3, '$.is_default_billing')::boolean)::integer END
WHERE id = $1 AND customer_id = $2 AND deleted_at IS NULL
  AND EXISTS (
    SELECT 1 FROM customers WHERE id = $2 AND deleted_at IS NULL
  )
''')
  Future<Result<ExecResult, SqlxError>> update(
    String addressId,
    String customerId,
    String patchJson,
  );
}
