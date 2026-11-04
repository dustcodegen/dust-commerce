import 'package:commerce_server/src/features/admin_customer/model.dart';
import 'package:dust_dart/db.dart';

part 'repository.g.dart';

/// Protected merchant customer-list persistence.
@SqlxDao()
abstract final class AdminCustomerRepository {
  /// Binds immutable customer reads to [db].
  const factory AdminCustomerRepository(Executor db) =
      _$AdminCustomerRepository;

  /// Lists the exact columns consumed by Medusa's merchant customer table.
  @Query(r'''
SELECT customer.id,
       customer.email,
       customer.first_name,
       customer.last_name,
       customer.has_account = 1 AS has_account,
       customer.created_at,
       customer.updated_at
FROM customers customer
WHERE customer.deleted_at IS NULL
  AND ($1 = '' OR lower(customer.id) LIKE '%' || lower($1) || '%'
       OR lower(coalesce(customer.email, '')) LIKE '%' || lower($1) || '%'
       OR lower(coalesce(customer.company_name, '')) LIKE '%' || lower($1) || '%'
       OR lower(coalesce(customer.first_name, '')) LIKE '%' || lower($1) || '%'
       OR lower(coalesce(customer.last_name, '')) LIKE '%' || lower($1) || '%'
       OR lower(trim(coalesce(customer.first_name, '') || ' ' ||
                     coalesce(customer.last_name, '')))
          LIKE '%' || lower($1) || '%')
  AND ($2 = -1 OR customer.has_account = $2)
  AND (NULLIF($3, '') IS NULL OR customer.created_at > NULLIF($3, '')::timestamptz)
  AND (NULLIF($4, '') IS NULL OR customer.created_at >= NULLIF($4, '')::timestamptz)
  AND (NULLIF($5, '') IS NULL OR customer.created_at < NULLIF($5, '')::timestamptz)
  AND (NULLIF($6, '') IS NULL OR customer.created_at <= NULLIF($6, '')::timestamptz)
  AND (NULLIF($7, '') IS NULL OR customer.updated_at > NULLIF($7, '')::timestamptz)
  AND (NULLIF($8, '') IS NULL OR customer.updated_at >= NULLIF($8, '')::timestamptz)
  AND (NULLIF($9, '') IS NULL OR customer.updated_at < NULLIF($9, '')::timestamptz)
  AND (NULLIF($10, '') IS NULL OR customer.updated_at <= NULLIF($10, '')::timestamptz)
  AND ($11 = '' OR EXISTS (
    SELECT 1
    FROM customer_group_customers membership
    JOIN customer_groups customer_group
      ON customer_group.id = membership.customer_group_id
    WHERE membership.customer_id = customer.id
      AND membership.customer_group_id = $11
      AND membership.deleted_at IS NULL
      AND customer_group.deleted_at IS NULL
  ))
ORDER BY
  CASE WHEN $12 = 'email' THEN lower(customer.email) END ASC,
  CASE WHEN $12 = '-email' THEN lower(customer.email) END DESC,
  CASE WHEN $12 = 'first_name' THEN lower(customer.first_name) END ASC,
  CASE WHEN $12 = '-first_name' THEN lower(customer.first_name) END DESC,
  CASE WHEN $12 = 'last_name' THEN lower(customer.last_name) END ASC,
  CASE WHEN $12 = '-last_name' THEN lower(customer.last_name) END DESC,
  CASE WHEN $12 = 'has_account' THEN customer.has_account END ASC,
  CASE WHEN $12 = '-has_account' THEN customer.has_account END DESC,
  CASE WHEN $12 = 'created_at' THEN customer.created_at END ASC,
  CASE WHEN $12 = '-created_at' THEN customer.created_at END DESC,
  CASE WHEN $12 = 'updated_at' THEN customer.updated_at END ASC,
  CASE WHEN $12 = '-updated_at' THEN customer.updated_at END DESC,
  customer.created_at DESC,
  customer.id
LIMIT $13 OFFSET $14
''')
  Future<Result<List<AdminCustomerResponse>, SqlxError>> list(
    String query,
    int hasAccount,
    String createdAfter,
    String createdFrom,
    String createdBefore,
    String createdTo,
    String updatedAfter,
    String updatedFrom,
    String updatedBefore,
    String updatedTo,
    String groupId,
    String order,
    int limit,
    int offset,
  );

  /// Counts rows with the same search and filter boundary.
  @Query(r'''
SELECT count(*)
FROM customers customer
WHERE customer.deleted_at IS NULL
  AND ($1 = '' OR lower(customer.id) LIKE '%' || lower($1) || '%'
       OR lower(coalesce(customer.email, '')) LIKE '%' || lower($1) || '%'
       OR lower(coalesce(customer.company_name, '')) LIKE '%' || lower($1) || '%'
       OR lower(coalesce(customer.first_name, '')) LIKE '%' || lower($1) || '%'
       OR lower(coalesce(customer.last_name, '')) LIKE '%' || lower($1) || '%'
       OR lower(trim(coalesce(customer.first_name, '') || ' ' ||
                     coalesce(customer.last_name, '')))
          LIKE '%' || lower($1) || '%')
  AND ($2 = -1 OR customer.has_account = $2)
  AND (NULLIF($3, '') IS NULL OR customer.created_at > NULLIF($3, '')::timestamptz)
  AND (NULLIF($4, '') IS NULL OR customer.created_at >= NULLIF($4, '')::timestamptz)
  AND (NULLIF($5, '') IS NULL OR customer.created_at < NULLIF($5, '')::timestamptz)
  AND (NULLIF($6, '') IS NULL OR customer.created_at <= NULLIF($6, '')::timestamptz)
  AND (NULLIF($7, '') IS NULL OR customer.updated_at > NULLIF($7, '')::timestamptz)
  AND (NULLIF($8, '') IS NULL OR customer.updated_at >= NULLIF($8, '')::timestamptz)
  AND (NULLIF($9, '') IS NULL OR customer.updated_at < NULLIF($9, '')::timestamptz)
  AND (NULLIF($10, '') IS NULL OR customer.updated_at <= NULLIF($10, '')::timestamptz)
  AND ($11 = '' OR EXISTS (
    SELECT 1
    FROM customer_group_customers membership
    JOIN customer_groups customer_group
      ON customer_group.id = membership.customer_group_id
    WHERE membership.customer_id = customer.id
      AND membership.customer_group_id = $11
      AND membership.deleted_at IS NULL
      AND customer_group.deleted_at IS NULL
  ))
''')
  Future<Result<int, SqlxError>> count(
    String query,
    int hasAccount,
    String createdAfter,
    String createdFrom,
    String createdBefore,
    String createdTo,
    String updatedAfter,
    String updatedFrom,
    String updatedBefore,
    String updatedTo,
    String groupId,
  );
}
