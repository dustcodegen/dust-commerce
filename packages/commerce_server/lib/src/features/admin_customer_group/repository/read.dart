import 'package:commerce_server/src/features/admin_customer_group/detail_response.dart';
import 'package:dust_dart/db.dart';

part 'read.g.dart';

/// Direct SQLx persistence for one active customer-group detail.
@SqlxDao()
abstract final class AdminCustomerGroupDetailRepository {
  /// Binds customer-group detail retrieval to [db].
  const factory AdminCustomerGroupDetailRepository(Executor db) =
      _$AdminCustomerGroupDetailRepository;

  /// Selects only the fields consumed by Medusa's group detail route.
  @Query(r'''
SELECT customer_group.id,
       customer_group.name,
       coalesce((
         SELECT json_agg(json_build_object('id', member.customer_id))
         FROM (
           SELECT membership.customer_id
           FROM customer_group_customers membership
           JOIN customers customer ON customer.id = membership.customer_id
           WHERE membership.customer_group_id = customer_group.id
             AND membership.deleted_at IS NULL
             AND customer.deleted_at IS NULL
           ORDER BY membership.created_at, membership.id
         ) member
       ), '[]')::text AS customers_json,
       coalesce(customer_group.metadata, 'null') AS metadata_json,
       customer_group.created_at,
       customer_group.updated_at
FROM customer_groups customer_group
WHERE customer_group.id = $1 AND customer_group.deleted_at IS NULL
''')
  Future<Result<AdminCustomerGroupDetailResponse?, SqlxError>> find(String id);
}
