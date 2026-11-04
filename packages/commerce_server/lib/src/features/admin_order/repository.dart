import 'package:commerce_server/src/features/admin_order/model.dart';
import 'package:dust_dart/db.dart';

part 'repository.g.dart';

/// Protected merchant order-list persistence.
@SqlxDao()
abstract final class AdminOrderRepository {
  /// Binds immutable order reads to [db].
  const factory AdminOrderRepository(Executor db) = _$AdminOrderRepository;

  /// Lists the exact columns consumed by Medusa's merchant order table.
  @Query(r'''
SELECT order_row.id,
       order_row.display_id,
       order_row.created_at,
       order_row.updated_at,
       order_row.email,
       coalesce(
         nullif(trim(coalesce(customer.first_name, '') || ' ' ||
                     coalesce(customer.last_name, '')), ''),
         order_row.email
       ) AS customer_name,
       order_row.status,
       order_row.payment_status,
       'not_fulfilled' AS fulfillment_status,
       order_row.total,
       order_row.currency_code,
       shipping.country_code,
       sales_channel.name AS sales_channel_name
FROM orders order_row
LEFT JOIN customers customer
  ON customer.id = order_row.customer_id AND customer.deleted_at IS NULL
LEFT JOIN order_addresses shipping
  ON shipping.order_id = order_row.id AND shipping.kind = 'shipping'
LEFT JOIN order_sales_channels channel_link
  ON channel_link.order_id = order_row.id
LEFT JOIN sales_channels sales_channel
  ON sales_channel.id = channel_link.sales_channel_id
WHERE order_row.deleted_at IS NULL
  AND ($1 = '' OR lower(order_row.id) LIKE '%' || lower($1) || '%'
       OR cast(order_row.display_id AS TEXT) LIKE '%' || $1 || '%'
       OR lower(order_row.email) LIKE '%' || lower($1) || '%'
       OR lower(coalesce(customer.first_name, '')) LIKE '%' || lower($1) || '%'
       OR lower(coalesce(customer.last_name, '')) LIKE '%' || lower($1) || '%'
       OR lower(trim(coalesce(customer.first_name, '') || ' ' ||
                     coalesce(customer.last_name, '')))
          LIKE '%' || lower($1) || '%')
  AND ($2 = '' OR instr(',' || $2 || ',',
                        ',' || order_row.status || ',') > 0)
  AND ($3 = '' OR instr(',' || $3 || ',',
                        ',' || order_row.region_id || ',') > 0)
  AND ($4 = '' OR instr(',' || $4 || ',',
                        ',' || channel_link.sales_channel_id || ',') > 0)
  AND ($5 = '' OR order_row.customer_id = $5)
  AND (NULLIF($6, '') IS NULL OR order_row.created_at > NULLIF($6, '')::timestamptz)
  AND (NULLIF($7, '') IS NULL OR order_row.created_at >= NULLIF($7, '')::timestamptz)
  AND (NULLIF($8, '') IS NULL OR order_row.created_at < NULLIF($8, '')::timestamptz)
  AND (NULLIF($9, '') IS NULL OR order_row.created_at <= NULLIF($9, '')::timestamptz)
  AND (NULLIF($10, '') IS NULL OR order_row.updated_at > NULLIF($10, '')::timestamptz)
  AND (NULLIF($11, '') IS NULL OR order_row.updated_at >= NULLIF($11, '')::timestamptz)
  AND (NULLIF($12, '') IS NULL OR order_row.updated_at < NULLIF($12, '')::timestamptz)
  AND (NULLIF($13, '') IS NULL OR order_row.updated_at <= NULLIF($13, '')::timestamptz)
ORDER BY
  CASE WHEN $14 = 'display_id' THEN order_row.display_id END ASC,
  CASE WHEN $14 = '-display_id' THEN order_row.display_id END DESC,
  CASE WHEN $14 = 'created_at' THEN order_row.created_at END ASC,
  CASE WHEN $14 = '-created_at' THEN order_row.created_at END DESC,
  CASE WHEN $14 = 'updated_at' THEN order_row.updated_at END ASC,
  CASE WHEN $14 = '-updated_at' THEN order_row.updated_at END DESC,
  order_row.display_id DESC
LIMIT $15 OFFSET $16
''')
  Future<Result<List<AdminOrderResponse>, SqlxError>> list(
    String query,
    String statuses,
    String regionIds,
    String salesChannelIds,
    String customerId,
    String createdAfter,
    String createdFrom,
    String createdBefore,
    String createdTo,
    String updatedAfter,
    String updatedFrom,
    String updatedBefore,
    String updatedTo,
    String order,
    int limit,
    int offset,
  );

  /// Counts rows with the same search and filter boundary.
  @Query(r'''
SELECT count(*)
FROM orders order_row
LEFT JOIN customers customer
  ON customer.id = order_row.customer_id AND customer.deleted_at IS NULL
LEFT JOIN order_sales_channels channel_link
  ON channel_link.order_id = order_row.id
WHERE order_row.deleted_at IS NULL
  AND ($1 = '' OR lower(order_row.id) LIKE '%' || lower($1) || '%'
       OR cast(order_row.display_id AS TEXT) LIKE '%' || $1 || '%'
       OR lower(order_row.email) LIKE '%' || lower($1) || '%'
       OR lower(coalesce(customer.first_name, '')) LIKE '%' || lower($1) || '%'
       OR lower(coalesce(customer.last_name, '')) LIKE '%' || lower($1) || '%'
       OR lower(trim(coalesce(customer.first_name, '') || ' ' ||
                     coalesce(customer.last_name, '')))
          LIKE '%' || lower($1) || '%')
  AND ($2 = '' OR instr(',' || $2 || ',',
                        ',' || order_row.status || ',') > 0)
  AND ($3 = '' OR instr(',' || $3 || ',',
                        ',' || order_row.region_id || ',') > 0)
  AND ($4 = '' OR instr(',' || $4 || ',',
                        ',' || channel_link.sales_channel_id || ',') > 0)
  AND ($5 = '' OR order_row.customer_id = $5)
  AND (NULLIF($6, '') IS NULL OR order_row.created_at > NULLIF($6, '')::timestamptz)
  AND (NULLIF($7, '') IS NULL OR order_row.created_at >= NULLIF($7, '')::timestamptz)
  AND (NULLIF($8, '') IS NULL OR order_row.created_at < NULLIF($8, '')::timestamptz)
  AND (NULLIF($9, '') IS NULL OR order_row.created_at <= NULLIF($9, '')::timestamptz)
  AND (NULLIF($10, '') IS NULL OR order_row.updated_at > NULLIF($10, '')::timestamptz)
  AND (NULLIF($11, '') IS NULL OR order_row.updated_at >= NULLIF($11, '')::timestamptz)
  AND (NULLIF($12, '') IS NULL OR order_row.updated_at < NULLIF($12, '')::timestamptz)
  AND (NULLIF($13, '') IS NULL OR order_row.updated_at <= NULLIF($13, '')::timestamptz)
''')
  Future<Result<int, SqlxError>> count(
    String query,
    String statuses,
    String regionIds,
    String salesChannelIds,
    String customerId,
    String createdAfter,
    String createdFrom,
    String createdBefore,
    String createdTo,
    String updatedAfter,
    String updatedFrom,
    String updatedBefore,
    String updatedTo,
  );
}
