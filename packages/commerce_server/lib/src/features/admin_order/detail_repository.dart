import 'package:commerce_server/src/features/admin_order/detail_model.dart';
import 'package:dust_dart/db.dart';
part 'detail_repository.g.dart';

/// Protected persistence for one complete merchant order snapshot.
@SqlxDao()
abstract final class AdminOrderDetailRepository {
  /// Binds immutable order-detail reads to [db].
  const factory AdminOrderDetailRepository(Executor db) =
      _$AdminOrderDetailRepository;

  /// Selects only the fields required by the read-only Admin detail screen.
  @Query(r'''
SELECT order_row.id, order_row.region_id, order_row.display_id, order_row.email,
       order_row.shipping_option_id, order_row.currency_code,
       order_row.subtotal, order_row.shipping_total, order_row.discount_total,
       order_row.tax, order_row.total, order_row.status, order_row.payment_status,
       coalesce(nullif(trim(coalesce(customer.first_name, '') || ' ' ||
         coalesce(customer.last_name, '')), ''), order_row.email) AS customer_name,
       CASE
         WHEN coalesce(fulfillment_summary.delivered_quantity, 0) >=
           order_summary.order_quantity THEN 'delivered'
         WHEN coalesce(fulfillment_summary.delivered_quantity, 0) > 0
           THEN 'partially_delivered'
         WHEN coalesce(fulfillment_summary.shipped_quantity, 0) >=
           order_summary.order_quantity THEN 'shipped'
         WHEN coalesce(fulfillment_summary.shipped_quantity, 0) > 0
           THEN 'partially_shipped'
         WHEN coalesce(fulfillment_summary.fulfilled_quantity, 0) >=
           order_summary.order_quantity THEN 'fulfilled'
         WHEN coalesce(fulfillment_summary.fulfilled_quantity, 0) > 0
           THEN 'partially_fulfilled'
         WHEN order_row.status = 'canceled' AND EXISTS (
           SELECT 1 FROM fulfillments canceled
           WHERE canceled.order_id = order_row.id
             AND canceled.canceled_at IS NOT NULL
         ) THEN 'canceled'
         ELSE 'not_fulfilled'
       END AS fulfillment_status,
       order_row.shipping_name, order_row.promotion_code, order_row.placed_at,
       order_row.created_at, order_row.updated_at,
       payment.id AS payment_id, payment.provider AS payment_provider,
       payment.amount AS payment_amount,
       payment.status AS payment_record_status, payment.created_at AS payment_created_at,
       payment.captured_at AS payment_captured_at,
       coalesce((SELECT sum(refund.amount) FROM refunds refund
                 WHERE refund.payment_collection_id = payment.id
                   AND refund.deleted_at IS NULL), 0) AS payment_refunded_amount,
       coalesce((SELECT json_agg(json_build_object(
         'id', refund.id, 'amount', refund.amount,
         'refund_reason', CASE WHEN refund.reason_id IS NULL THEN NULL ELSE
           json_build_object('id', refund.reason_id, 'label', refund.reason_label,
             'code', refund.reason_code, 'description', refund.reason_description) END,
         'note', refund.note, 'created_by', refund.created_by, 'created_at', refund.created_at
       )) FROM (
         SELECT record.*, reason.id AS reason_id, reason.label AS reason_label,
                reason.code AS reason_code, reason.description AS reason_description
         FROM refunds record
         LEFT JOIN refund_reasons reason ON reason.id = record.refund_reason_id
         WHERE record.payment_collection_id = payment.id
           AND record.deleted_at IS NULL
         ORDER BY record.created_at, record.id
       ) refund), '[]'::json)::text AS payment_refunds_json,
       coalesce((
         SELECT json_agg(json_build_object(
           'id', item.id, 'variant_id', item.variant_id, 'product_id', item.product_id,
           'shipping_profile_id', item.shipping_profile_id,
           'product_handle', item.product_handle, 'thumbnail', item.thumbnail,
           'title', item.title, 'variant_title', item.variant_title,
           'unit_amount', item.unit_amount, 'currency_code', item.currency_code,
           'quantity', item.quantity, 'created_at', item.created_at
         ))
         FROM (
           SELECT item_row.*, profile_link.shipping_profile_id
           FROM order_items item_row
           LEFT JOIN product_shipping_profile profile_link
             ON profile_link.product_id = item_row.product_id
            AND profile_link.deleted_at IS NULL
           WHERE order_id = order_row.id
           ORDER BY created_at, id
         ) item
       ), '[]'::json)::text AS items_json,
       coalesce((
         SELECT json_agg(json_build_object(
           'id', fulfillment.id, 'location_id', fulfillment.location_id,
           'provider_id', fulfillment.provider_id,
           'shipping_option_id', fulfillment.shipping_option_id,
           'requires_shipping', dust_json_value(iif(
             fulfillment.requires_shipping = 1, 'true', 'false'
           )),
           'packed_at', fulfillment.packed_at, 'shipped_at', fulfillment.shipped_at,
           'delivered_at', fulfillment.delivered_at, 'canceled_at', fulfillment.canceled_at,
           'data', CASE WHEN fulfillment.data IS NULL THEN NULL
                        ELSE dust_json_value(fulfillment.data) END,
           'metadata', CASE WHEN fulfillment.metadata IS NULL THEN NULL
                            ELSE dust_json_value(fulfillment.metadata) END,
           'created_by', fulfillment.created_by, 'marked_shipped_by', fulfillment.marked_shipped_by,
           'created_at', fulfillment.created_at, 'updated_at', fulfillment.updated_at,
           'items', dust_json_value(fulfillment.items_json), 'labels', dust_json_value(fulfillment.labels_json)
         ))
         FROM (
           SELECT record.*, coalesce((
             SELECT json_agg(json_build_object(
               'id', item.id,
               'fulfillment_id', item.fulfillment_id,
               'title', item.title,
               'quantity', item.quantity,
               'sku', item.sku,
               'barcode', item.barcode,
               'line_item_id', item.line_item_id,
               'inventory_item_id', item.inventory_item_id,
               'created_at', item.created_at,
               'updated_at', item.updated_at
             ))
             FROM (
               SELECT * FROM fulfillment_items
               WHERE fulfillment_id = record.id AND deleted_at IS NULL
               ORDER BY created_at, id
             ) item
           ), '[]') AS items_json,
           coalesce((
             SELECT json_agg(json_build_object(
               'id', label.id, 'fulfillment_id', label.fulfillment_id,
               'tracking_number', label.tracking_number,
               'tracking_url', label.tracking_url, 'label_url', label.label_url,
               'created_at', label.created_at, 'updated_at', label.updated_at
             ))
             FROM (
               SELECT * FROM fulfillment_labels
               WHERE fulfillment_id = record.id AND deleted_at IS NULL
               ORDER BY created_at, id
             ) label
           ), '[]') AS labels_json
           FROM fulfillments record WHERE record.order_id = order_row.id
             AND record.deleted_at IS NULL
           ORDER BY record.created_at, record.id
         ) fulfillment
       ), '[]'::json)::text AS fulfillments_json,
       CASE WHEN shipping.order_id IS NULL THEN NULL ELSE json_build_object(
         'first_name', shipping.first_name, 'last_name', shipping.last_name,
         'company', shipping.company, 'line1', shipping.line1,
         'line2', shipping.line2, 'city', shipping.city,
         'province', shipping.province, 'postal_code', shipping.postal_code,
         'country_code', shipping.country_code,
         'phone', shipping.phone
       ) END::text AS shipping_address_json,
       CASE WHEN billing.order_id IS NULL THEN NULL ELSE json_build_object(
         'first_name', billing.first_name, 'last_name', billing.last_name,
         'company', billing.company, 'line1', billing.line1,
         'line2', billing.line2, 'city', billing.city,
         'province', billing.province, 'postal_code', billing.postal_code,
         'country_code', billing.country_code,
         'phone', billing.phone
       ) END::text AS billing_address_json
FROM orders order_row
LEFT JOIN customers customer ON customer.id = order_row.customer_id AND customer.deleted_at IS NULL
LEFT JOIN order_addresses shipping ON shipping.order_id = order_row.id AND shipping.kind = 'shipping'
LEFT JOIN order_addresses billing ON billing.order_id = order_row.id AND billing.kind = 'billing'
LEFT JOIN payment_collections payment
  ON payment.order_id = order_row.id AND payment.deleted_at IS NULL
LEFT JOIN (
  SELECT order_id, sum(quantity) AS order_quantity FROM order_items GROUP BY order_id
) order_summary ON order_summary.order_id = order_row.id
LEFT JOIN (
  SELECT fulfillment.order_id,
         sum(item.quantity) AS fulfilled_quantity,
         sum(iif(fulfillment.shipped_at IS NULL, 0, item.quantity))
           AS shipped_quantity,
         sum(iif(fulfillment.delivered_at IS NULL, 0, item.quantity))
           AS delivered_quantity
  FROM fulfillments fulfillment
  JOIN fulfillment_items item ON item.fulfillment_id = fulfillment.id
    AND item.deleted_at IS NULL
  WHERE fulfillment.deleted_at IS NULL AND fulfillment.canceled_at IS NULL
  GROUP BY fulfillment.order_id
) fulfillment_summary ON fulfillment_summary.order_id = order_row.id
WHERE order_row.id = $1 AND order_row.deleted_at IS NULL
''')
  Future<Result<AdminOrderDetailResponse?, SqlxError>> find(String id);
}
