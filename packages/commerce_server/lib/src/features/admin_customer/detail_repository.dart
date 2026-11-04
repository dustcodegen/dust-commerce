import 'package:commerce_server/src/features/admin_customer/detail_model.dart';
import 'package:dust_dart/db.dart';

part 'detail_repository.g.dart';

/// Protected persistence for one complete merchant customer profile.
@SqlxDao()
abstract final class AdminCustomerDetailRepository {
  /// Binds immutable customer-detail reads to [db].
  const factory AdminCustomerDetailRepository(Executor db) =
      _$AdminCustomerDetailRepository;

  /// Selects the profile and active address fields used by Medusa's detail.
  @Query(r'''
SELECT customer.id,
       customer.email,
       customer.company_name,
       customer.first_name,
       customer.last_name,
       customer.phone,
       customer.has_account = 1 AS has_account,
       customer.created_at,
       customer.updated_at,
       coalesce((
         SELECT json_agg(json_build_object(
           'id', address.id,
           'address_name', address.address_name,
           'first_name', address.first_name,
           'last_name', address.last_name,
           'company', address.company,
           'phone', address.phone,
           'address_1', address.address_1,
           'address_2', address.address_2,
           'city', address.city,
           'province', address.province,
           'postal_code', address.postal_code,
           'country_code', address.country_code,
           'is_default_shipping', dust_json_value(iif(
             address.is_default_shipping = 1, 'true', 'false'
           )),
           'is_default_billing', dust_json_value(iif(
             address.is_default_billing = 1, 'true', 'false'
           ))
         ))
         FROM (
           SELECT * FROM customer_addresses
           WHERE customer_id = customer.id AND deleted_at IS NULL
           ORDER BY is_default_shipping DESC, is_default_billing DESC,
                    created_at, id
         ) address
       ), '[]'::json)::text AS addresses_json
FROM customers customer
WHERE customer.id = $1 AND customer.deleted_at IS NULL
''')
  Future<Result<AdminCustomerDetailResponse?, SqlxError>> find(String id);
}
