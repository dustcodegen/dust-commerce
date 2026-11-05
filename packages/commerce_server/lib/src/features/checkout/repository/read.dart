import 'package:commerce_server/src/features/checkout/model.dart';
import 'package:dust_dart/db.dart';

part 'read.g.dart';

/// The reads that load one complete order response.
@SqlxDao()
abstract final class CheckoutReadRepository {
  /// Binds the queries to [db].
  const factory CheckoutReadRepository(Executor db) = _$CheckoutReadRepository;

  /// One complete order, including frozen lines and addresses.
  @Query(r'''
WITH order_summary AS (
  SELECT order_id, sum(quantity) AS order_quantity
  FROM order_items GROUP BY order_id
), fulfillment_summary AS (
  SELECT fulfillment.order_id, sum(item.quantity) AS fulfilled_quantity,
         sum(iif(fulfillment.shipped_at IS NULL, 0, item.quantity))
           AS shipped_quantity,
         sum(iif(fulfillment.delivered_at IS NULL, 0, item.quantity))
           AS delivered_quantity
  FROM fulfillments fulfillment
  JOIN fulfillment_items item
    ON item.fulfillment_id = fulfillment.id AND item.deleted_at IS NULL
  WHERE fulfillment.deleted_at IS NULL AND fulfillment.canceled_at IS NULL
  GROUP BY fulfillment.order_id
)
SELECT o.id, o.display_id, o.email, o.customer_id, o.currency_code, o.subtotal,
       o.shipping_total, o.discount_total, o.tax, o.total, o.status,
       o.payment_status,
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
         WHEN o.status = 'canceled' AND EXISTS (
           SELECT 1 FROM fulfillments canceled
           WHERE canceled.order_id = o.id AND canceled.canceled_at IS NOT NULL
         ) THEN 'canceled'
         ELSE 'not_fulfilled'
       END AS fulfillment_status,
       o.placed_at, o.region_id,
       o.shipping_option_id, o.shipping_name,
       coalesce((SELECT fulfillment_type FROM shipping_option_fulfillments
                 WHERE shipping_option_id = o.shipping_option_id), 'shipping')
         AS shipping_fulfillment_type,
       (SELECT pickup_name FROM shipping_option_fulfillments
        WHERE shipping_option_id = o.shipping_option_id) AS shipping_pickup_name,
       (SELECT pickup_address FROM shipping_option_fulfillments
        WHERE shipping_option_id = o.shipping_option_id) AS shipping_pickup_address,
       payment.provider AS payment_provider, payment.amount AS payment_amount,
       payment.created_at AS payment_created_at,
       r.name AS region_name, r.tax_rate,
       r.tax_inclusive = 1 AS tax_inclusive,
       string_to_array(r.countries, ',') AS countries,
       coalesce((
         SELECT json_agg(json_build_object(
           'id', i.id, 'variant_id', i.variant_id,
           'product_id', i.product_id, 'product_handle', i.product_handle,
           'thumbnail', i.thumbnail, 'title', i.title,
           'variant_title', i.variant_title,
           'unit_price', json_build_object('amount', i.unit_amount,
                                     'currency_code', i.currency_code),
           'quantity', i.quantity,
           'detail', json_build_object(
             'delivered_quantity', coalesce((
               SELECT sum(delivered_item.quantity)
               FROM fulfillment_items delivered_item
               JOIN fulfillments delivered
                 ON delivered.id = delivered_item.fulfillment_id
               WHERE delivered_item.line_item_id = i.id
                 AND delivered_item.deleted_at IS NULL
                 AND delivered.deleted_at IS NULL
                 AND delivered.canceled_at IS NULL
                 AND delivered.delivered_at IS NOT NULL
             ), 0),
             'return_requested_quantity', coalesce(returned.requested_quantity, 0),
             'return_received_quantity', coalesce(returned.received_quantity, 0),
             'return_dismissed_quantity', coalesce(returned.dismissed_quantity, 0)
           )
         ) ORDER BY i.created_at DESC, i.id DESC)
         FROM order_items i
         LEFT JOIN (
           SELECT item.order_item_id,
                  SUM(CASE WHEN request.status IN ('open', 'requested')
                    THEN item.quantity WHEN request.status = 'partially_received'
                    THEN item.quantity - item.received_quantity
                    ELSE 0 END) AS requested_quantity,
                  SUM(CASE WHEN request.status IN ('received', 'partially_received')
                    THEN item.received_quantity - item.damaged_quantity
                    ELSE 0 END) AS received_quantity,
                  SUM(CASE WHEN request.status IN ('received', 'partially_received')
                    THEN item.damaged_quantity ELSE 0 END) AS dismissed_quantity
           FROM return_items item
           JOIN return_requests request ON request.id = item.return_id
           WHERE request.status <> 'canceled' AND request.deleted_at IS NULL
           GROUP BY item.order_item_id
         ) returned ON returned.order_item_id = i.id
         WHERE i.order_id = o.id
       ), '[]')::text AS items_json,
       json_build_object(
         'first_name', shipping.first_name, 'last_name', shipping.last_name,
         'company', shipping.company,
         'line1', shipping.line1, 'line2', shipping.line2,
         'city', shipping.city, 'province', shipping.province,
         'postal_code', shipping.postal_code,
         'country_code', shipping.country_code, 'phone', shipping.phone
       )::text AS shipping_address_json,
       json_build_object(
         'first_name', coalesce(billing.first_name, shipping.first_name),
         'last_name', coalesce(billing.last_name, shipping.last_name),
         'company', CASE WHEN billing.order_id IS NULL
                         THEN shipping.company ELSE billing.company END,
         'line1', coalesce(billing.line1, shipping.line1),
         'line2', CASE WHEN billing.order_id IS NULL
                       THEN shipping.line2 ELSE billing.line2 END,
         'city', coalesce(billing.city, shipping.city),
         'province', CASE WHEN billing.order_id IS NULL
                          THEN shipping.province ELSE billing.province END,
         'postal_code', coalesce(billing.postal_code, shipping.postal_code),
         'country_code', coalesce(billing.country_code, shipping.country_code),
         'phone', CASE WHEN billing.order_id IS NULL
                       THEN shipping.phone ELSE billing.phone END
       )::text AS billing_address_json
FROM orders o
JOIN regions r ON r.id = o.region_id
JOIN order_addresses shipping ON shipping.order_id = o.id AND shipping.kind = 'shipping'
LEFT JOIN order_addresses billing ON billing.order_id = o.id AND billing.kind = 'billing'
LEFT JOIN payment_collections payment ON payment.order_id = o.id AND payment.deleted_at IS NULL
LEFT JOIN order_summary ON order_summary.order_id = o.id
LEFT JOIN fulfillment_summary ON fulfillment_summary.order_id = o.id
WHERE o.id = $1
''')
  Future<Result<OrderResponse?, SqlxError>> findOrder(String id);

  /// Existing order id for a cart, used to make checkout retry-safe.
  @Query(r'''
SELECT id FROM orders WHERE cart_id = $1 AND deleted_at IS NULL
''')
  Future<Result<String?, SqlxError>> orderIdForCart(String cartId);
}
