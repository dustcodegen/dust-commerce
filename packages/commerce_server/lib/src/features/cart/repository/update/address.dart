import 'package:dust_dart/db.dart';

part 'address.g.dart';

/// Writes checkout destinations without widening the cart table.
@SqlxDao()
abstract final class CartAddressRepository {
  /// Binds the address writes to [db].
  const factory CartAddressRepository(Executor db) = _$CartAddressRepository;

  /// Inserts or replaces one active cart destination.
  @Query(r'''
INSERT INTO cart_addresses
  (cart_id, kind, first_name, last_name, company, line1, line2, city,
   province, postal_code, country_code, phone)
SELECT $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12
FROM carts
WHERE id = $1 AND completed_at IS NULL AND deleted_at IS NULL
ON CONFLICT (cart_id, kind) DO UPDATE SET
  first_name = excluded.first_name,
  last_name = excluded.last_name,
  company = excluded.company,
  line1 = excluded.line1,
  line2 = excluded.line2,
  city = excluded.city,
  province = excluded.province,
  postal_code = excluded.postal_code,
  country_code = excluded.country_code,
  phone = excluded.phone
''')
  Future<Result<ExecResult, SqlxError>> upsertAddress(
    String cartId,
    String kind,
    String firstName,
    String lastName,
    String? company,
    String line1,
    String? line2,
    String city,
    String? province,
    String postalCode,
    String countryCode,
    String? phone,
  );

  /// Removes a separate billing destination when shipping is reused.
  @Query(r'''
DELETE FROM cart_addresses WHERE cart_id = $1 AND kind = 'billing'
''')
  Future<Result<ExecResult, SqlxError>> clearBilling(String cartId);
}
