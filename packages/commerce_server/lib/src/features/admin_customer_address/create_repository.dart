import 'package:dust_dart/db.dart';

part 'create_repository.g.dart';

/// Direct SQLx persistence for merchant-created customer addresses.
@SqlxDao()
abstract final class AdminCustomerAddressCreateRepository {
  /// Binds address creation to [db].
  const factory AdminCustomerAddressCreateRepository(Executor db) =
      _$AdminCustomerAddressCreateRepository;

  /// Inserts beneath one active customer and lets PostgreSQL own audit timestamps.
  @Query(r'''
INSERT INTO customer_addresses (
  id, customer_id, address_name, first_name, last_name, company, phone,
  address_1, address_2, city, country_code, province, postal_code,
  is_default_shipping, is_default_billing
)
SELECT $1, $2, $3, nullif($4, ''), nullif($5, ''), nullif($6, ''),
       nullif($7, ''), $8, nullif($9, ''), nullif($10, ''), $11,
       nullif($12, ''), nullif($13, ''), $14, $15
WHERE EXISTS (
  SELECT 1 FROM customers WHERE id = $2 AND deleted_at IS NULL
)
''')
  Future<Result<ExecResult, SqlxError>> insert(
    String id,
    String customerId,
    String addressName,
    String? firstName,
    String? lastName,
    String? company,
    String? phone,
    String line1,
    String? line2,
    String? city,
    String countryCode,
    String? province,
    String? postalCode,
    int isDefaultShipping,
    int isDefaultBilling,
  );
}
