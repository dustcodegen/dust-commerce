import 'package:commerce_server/src/features/cart/model/cart.dart';
import 'package:commerce_server/src/features/cart/model/line_item.dart';
import 'package:commerce_server/src/features/cart/model/promotion.dart';
import 'package:dust_dart/db.dart';

part 'read.g.dart';

/// The reads that load a cart and its lines.
@SqlxDao()
abstract final class CartReadRepository {
  /// Binds the queries to [db].
  const factory CartReadRepository(Executor db) = _$CartReadRepository;

  /// Whether the cart's retained provider is still enabled for its region.
  @Query(r'''
SELECT CASE WHEN EXISTS (
  SELECT 1
  FROM carts
  JOIN cart_payment_sessions
    ON cart_payment_sessions.cart_id = carts.id
  JOIN region_payment_providers
    ON region_payment_providers.region_id = carts.region_id
   AND region_payment_providers.provider_id = cart_payment_sessions.provider_id
   AND region_payment_providers.enabled = 1
  WHERE carts.id = $1
  ) THEN 1 ELSE 0 END
''')
  Future<Result<int, SqlxError>> hasEnabledPaymentProvider(String cartId);

  /// One cart with the region that fixes its currency and tax.
  ///
  /// Joined rather than fetched in two calls: a cart without its region cannot
  /// total anything, so there is no useful state in which one is loaded
  /// without the other.
  @Query(r'''
SELECT c.id, c.customer_id, c.email,
       json_build_object(
         'id', r.id,
         'name', r.name,
         'currency_code', r.currency_code,
         'tax_rate', r.tax_rate,
         'tax_inclusive', r.tax_inclusive = 1,
         'countries', string_to_array(r.countries, ',')
       )::text AS region,
       coalesce((
         SELECT json_agg(dust_json_value(ordered.line_json))
         FROM (
           SELECT json_build_object(
             'id', line.id,
             'variant_id', line.variant_id,
             'product_id', line.product_id,
             'product_handle', line.product_handle,
             'thumbnail', line.thumbnail,
             'title', line.title,
             'variant_title', line.variant_title,
             'unit_price', json_build_object(
               'amount', line.unit_amount,
               'currency_code', line.currency_code
             ),
             'quantity', line.quantity
           ) AS line_json
           FROM line_items line
           WHERE line.cart_id = c.id
           ORDER BY line.id
         ) ordered
       ), '[]')::text AS items,
       coalesce((
         SELECT json_build_object(
           'option_id', method.option_id,
           'name', method.name,
           'amount', json_build_object(
             'amount', method.amount,
             'currency_code', r.currency_code
           ),
           'fulfillment_type',
             coalesce(fulfillment.fulfillment_type, 'shipping'),
           'pickup_name', fulfillment.pickup_name,
           'pickup_address', fulfillment.pickup_address
         )
         FROM cart_shipping_methods method
         LEFT JOIN shipping_option_fulfillments fulfillment
           ON fulfillment.shipping_option_id = method.option_id
         WHERE method.cart_id = c.id
       ), 'null')::text AS shipping_method,
       coalesce((
         SELECT json_build_object('provider_id', session.provider_id)
         FROM cart_payment_sessions session
         WHERE session.cart_id = c.id
       ), 'null')::text AS payment_session,
       coalesce((
         SELECT json_build_object(
           'first_name', address.first_name,
           'last_name', address.last_name,
           'company', address.company,
           'line1', address.line1,
           'line2', address.line2,
           'city', address.city,
           'province', address.province,
           'postal_code', address.postal_code,
           'country_code', address.country_code,
           'phone', address.phone
         )
         FROM cart_addresses address
         WHERE address.cart_id = c.id AND address.kind = 'shipping'
       ), 'null')::text AS shipping_address,
       coalesce((
         SELECT json_build_object(
           'first_name', address.first_name,
           'last_name', address.last_name,
           'company', address.company,
           'line1', address.line1,
           'line2', address.line2,
           'city', address.city,
           'province', address.province,
           'postal_code', address.postal_code,
           'country_code', address.country_code,
           'phone', address.phone
         )
         FROM cart_addresses address
         WHERE address.cart_id = c.id AND address.kind = 'billing'
       ), 'null')::text AS billing_address,
       coalesce((
         SELECT json_agg(dust_json_value(ordered.promotion_json))
         FROM (
           SELECT json_build_object(
             'id', promotion.promotion_id,
             'code', promotion.code,
             'type', promotion.type,
             'value', promotion.value,
             'currency_code', promotion.currency_code,
             'amount', json_build_object(
               'amount', promotion.amount,
               'currency_code', r.currency_code
             )
           ) AS promotion_json
           FROM cart_promotions promotion
           WHERE promotion.cart_id = c.id
           ORDER BY promotion.promotion_id
         ) ordered
       ), '[]')::text AS promotions
FROM carts c
JOIN regions r ON r.id = c.region_id
WHERE c.id = $1
''')
  Future<Result<CartResponse?, SqlxError>> findCart(String id);

  /// The lines of [cartId], in insertion order.
  @Query(r'''
SELECT id, variant_id, product_id, product_handle, thumbnail, title, variant_title,
       json_build_object('amount', unit_amount, 'currency_code', currency_code)::text AS unit_price,
       quantity
FROM line_items
WHERE cart_id = $1
ORDER BY id
''')
  Future<Result<List<LineItemResponse>, SqlxError>> linesOf(String cartId);

  /// The promotion [cartId] has applied, if it has one.
  @Query(r'''
SELECT promotion.promotion_id AS id, promotion.code, promotion.type,
       promotion.value, promotion.currency_code,
       json_build_object(
         'amount', amount,
         'currency_code', region.currency_code
       )::text AS amount
FROM cart_promotions promotion
JOIN carts cart ON cart.id = promotion.cart_id
JOIN regions region ON region.id = cart.region_id
WHERE promotion.cart_id = $1
''')
  Future<Result<AppliedPromotionResponse?, SqlxError>> promotionOn(
    String cartId,
  );

  /// One promotion by the code a customer typed.
  ///
  /// Matched upper case in SQL so entry is not case sensitive, which is a
  /// property of the lookup rather than something every caller remembers.
  @Query(r'''
SELECT id, code, type, value, currency_code,
       starts_at, ends_at,
       usage_limit, usage_count
FROM promotions
WHERE code = UPPER($1) AND deleted_at IS NULL
''')
  Future<Result<PromotionPolicy?, SqlxError>> promotionByCode(String code);

  /// The line for [variantId] in [cartId], if the cart already holds one.
  @Query(r'''
SELECT id, variant_id, product_id, product_handle, thumbnail, title, variant_title,
       json_build_object('amount', unit_amount, 'currency_code', currency_code)::text AS unit_price,
       quantity
FROM line_items
WHERE cart_id = $1 AND variant_id = $2
''')
  Future<Result<LineItemResponse?, SqlxError>> findLine(
    String cartId,
    String variantId,
  );

  /// One line proven to belong to [cartId].
  @Query(r'''
SELECT id, variant_id, product_id, product_handle, thumbnail, title,
       variant_title,
       json_build_object('amount', unit_amount, 'currency_code', currency_code)::text
         AS unit_price,
       quantity
FROM line_items
WHERE cart_id = $1 AND id = $2
''')
  Future<Result<LineItemResponse?, SqlxError>> findLineById(
    String cartId,
    String lineId,
  );
}
