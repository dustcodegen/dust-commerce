import 'package:commerce_server/src/features/account/model.dart';
import 'package:dust_dart/db.dart';

part 'list.g.dart';

/// Customer-owned address-book listings.
@SqlxDao()
abstract final class AccountListRepository {
  /// Binds the query to [db].
  const factory AccountListRepository(Executor db) = _$AccountListRepository;

  /// Lists only active addresses owned by the authenticated customer.
  @Query(r'''
SELECT id, first_name, last_name, company, phone, address_1, address_2,
       city, province, postal_code, country_code,
       is_default_shipping, is_default_billing
FROM customer_addresses
WHERE customer_id = $1 AND deleted_at IS NULL
ORDER BY is_default_shipping DESC, is_default_billing DESC, created_at, id
''')
  Future<Result<List<CustomerAddressResponse>, SqlxError>> addresses(
    String customerId,
  );
}
