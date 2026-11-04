import 'package:commerce_server/src/features/admin_order/export_model.dart';
import 'package:dust_dart/db.dart';

part 'export_repository.g.dart';

/// Direct filtered reads for merchant order CSV export.
@SqlxDao()
abstract final class AdminOrderExportRepository {
  /// Binds order export reads to [db].
  const factory AdminOrderExportRepository(Executor db) =
      _$AdminOrderExportRepository;

  /// Reads every matching order and frozen item in stable table order.
  @Query(r'''
SELECT order_row.id AS order_id, order_row.display_id, order_row.status,
       order_row.payment_status, 'not_fulfilled' AS fulfillment_status,
       order_row.created_at, order_row.updated_at, order_row.email,
       coalesce(nullif(trim(coalesce(customer.first_name, '') || ' ' ||
                            coalesce(customer.last_name, '')), ''),
                order_row.email) AS customer_name,
       order_row.currency_code, order_row.subtotal, order_row.shipping_total,
       order_row.discount_total, order_row.tax AS tax_total, order_row.total,
       order_row.shipping_name, order_row.promotion_code,
       item.id AS item_id, item.title AS item_title,
       item.variant_title AS item_variant_title,
       item.quantity AS item_quantity, item.unit_amount AS item_unit_amount,
       nullif(trim(coalesce(shipping.first_name, '') || ' ' ||
                   coalesce(shipping.last_name, '')), '') AS shipping_recipient,
       shipping.company AS shipping_company, shipping.line1 AS shipping_line1,
       shipping.line2 AS shipping_line2, shipping.city AS shipping_city,
       shipping.province AS shipping_province,
       shipping.postal_code AS shipping_postal_code,
       shipping.country_code AS shipping_country_code,
       shipping.phone AS shipping_phone,
       nullif(trim(coalesce(billing.first_name, '') || ' ' ||
                   coalesce(billing.last_name, '')), '') AS billing_recipient,
       billing.company AS billing_company, billing.line1 AS billing_line1,
       billing.line2 AS billing_line2, billing.city AS billing_city,
       billing.province AS billing_province,
       billing.postal_code AS billing_postal_code,
       billing.country_code AS billing_country_code,
       billing.phone AS billing_phone,
       payment.provider AS payment_provider, payment.amount AS payment_amount,
       payment.status AS payment_record_status,
       payment.captured_at AS payment_captured_at
FROM orders order_row
LEFT JOIN customers customer
  ON customer.id=order_row.customer_id AND customer.deleted_at IS NULL
LEFT JOIN order_items item ON item.order_id=order_row.id
LEFT JOIN order_addresses shipping
  ON shipping.order_id=order_row.id AND shipping.kind='shipping'
LEFT JOIN order_addresses billing
  ON billing.order_id=order_row.id AND billing.kind='billing'
LEFT JOIN payment_collections payment
  ON payment.order_id=order_row.id AND payment.deleted_at IS NULL
LEFT JOIN order_sales_channels channel_link
  ON channel_link.order_id=order_row.id
WHERE order_row.deleted_at IS NULL
  AND ($1='' OR lower(order_row.id) LIKE '%'||lower($1)||'%'
       OR cast(order_row.display_id AS TEXT) LIKE '%'||$1||'%'
       OR lower(order_row.email) LIKE '%'||lower($1)||'%'
       OR lower(coalesce(customer.first_name,'')) LIKE '%'||lower($1)||'%'
       OR lower(coalesce(customer.last_name,'')) LIKE '%'||lower($1)||'%'
       OR lower(trim(coalesce(customer.first_name,'')||' '||
                     coalesce(customer.last_name,''))) LIKE '%'||lower($1)||'%')
  AND ($2='' OR instr(','||$2||',', ','||order_row.status||',')>0)
  AND ($3='' OR instr(','||$3||',', ','||order_row.region_id||',')>0)
  AND ($4='' OR instr(','||$4||',',
                      ','||channel_link.sales_channel_id||',')>0)
  AND (NULLIF($5, '') IS NULL OR order_row.created_at > NULLIF($5, '')::timestamptz)
  AND (NULLIF($6, '') IS NULL OR order_row.created_at >= NULLIF($6, '')::timestamptz)
  AND (NULLIF($7, '') IS NULL OR order_row.created_at < NULLIF($7, '')::timestamptz)
  AND (NULLIF($8, '') IS NULL OR order_row.created_at <= NULLIF($8, '')::timestamptz)
  AND (NULLIF($9, '') IS NULL OR order_row.updated_at > NULLIF($9, '')::timestamptz)
  AND (NULLIF($10, '') IS NULL OR order_row.updated_at >= NULLIF($10, '')::timestamptz)
  AND (NULLIF($11, '') IS NULL OR order_row.updated_at < NULLIF($11, '')::timestamptz)
  AND (NULLIF($12, '') IS NULL OR order_row.updated_at <= NULLIF($12, '')::timestamptz)
ORDER BY
  CASE WHEN $13='display_id' THEN order_row.display_id END ASC,
  CASE WHEN $13='-display_id' THEN order_row.display_id END DESC,
  CASE WHEN $13='created_at' THEN order_row.created_at END ASC,
  CASE WHEN $13='-created_at' THEN order_row.created_at END DESC,
  CASE WHEN $13='updated_at' THEN order_row.updated_at END ASC,
  CASE WHEN $13='-updated_at' THEN order_row.updated_at END DESC,
  order_row.display_id DESC, item.created_at, item.id
''')
  Future<Result<List<AdminOrderExportRow>, SqlxError>> list(
    String query,
    String statuses,
    String regionIds,
    String salesChannelIds,
    String createdAfter,
    String createdFrom,
    String createdBefore,
    String createdTo,
    String updatedAfter,
    String updatedFrom,
    String updatedBefore,
    String updatedTo,
    String order,
  );
}
