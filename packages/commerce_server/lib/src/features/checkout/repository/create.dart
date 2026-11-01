import 'package:dust_dart/db.dart';

part 'create.g.dart';

/// The writes that turn a cart into an order.
@SqlxDao()
abstract final class CheckoutCreateRepository {
  /// Binds the queries to [db].
  const factory CheckoutCreateRepository(Executor db) =
      _$CheckoutCreateRepository;

  /// Writes the order header with its totals already computed.
  @Query(r'''
INSERT INTO orders (id, display_id, cart_id, region_id, customer_id, email,
                    currency_code,
                    subtotal, shipping_total, discount_total, tax, total,
                    shipping_option_id, shipping_name, promotion_code,
                    placed_at)
SELECT $1, coalesce(max(display_id), 0) + 1, $2, $3, $4, $5, $6, $7, $8,
       $9, $10, $11, $12, $13, $14, $15
FROM orders
''')
  Future<Result<ExecResult, SqlxError>> insertOrder(
    String id,
    String cartId,
    String regionId,
    String? customerId,
    String email,
    String currencyCode,
    int subtotal,
    int shippingTotal,
    int discountTotal,
    int tax,
    int total,
    String? shippingOptionId,
    String? shippingName,
    String? promotionCode,
    String placedAt,
  );

  /// Creates or refreshes one checkout-only profile without credentials.
  @Query(r'''
INSERT INTO customers
  (id, email, company_name, first_name, last_name, phone, has_account)
VALUES ($1, $2, $3, $4, $5, $6, 0)
ON CONFLICT(email, has_account)
  WHERE email IS NOT NULL AND deleted_at IS NULL
DO UPDATE SET company_name = excluded.company_name,
              first_name = excluded.first_name,
              last_name = excluded.last_name,
              phone = excluded.phone
''')
  Future<Result<ExecResult, SqlxError>> upsertGuestCustomer(
    String id,
    String email,
    String? companyName,
    String firstName,
    String lastName,
    String? phone,
  );

  /// Copies one cart line onto the order.
  @Query(r'''
INSERT INTO order_items (id, order_id, variant_id, product_id, product_handle,
                         thumbnail, title, variant_title, unit_amount,
                         currency_code, quantity)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
''')
  Future<Result<ExecResult, SqlxError>> insertOrderItem(
    String id,
    String orderId,
    String variantId,
    String productId,
    String productHandle,
    String? thumbnail,
    String title,
    String? variantTitle,
    int unitAmount,
    String currencyCode,
    int quantity,
  );

  /// Records the shipping or billing address used for an order.
  @Query(r'''
INSERT INTO order_addresses (order_id, kind, first_name, last_name, company,
                             line1, line2, city, province, postal_code,
                             country_code, phone)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
''')
  Future<Result<ExecResult, SqlxError>> insertOrderAddress(
    String orderId,
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

  /// Takes managed stock for a variant, but only if there is enough.
  ///
  /// The check is in the WHERE clause rather than in Dart: two checkouts
  /// racing for the last unit both read "one left", and only the write can
  /// decide which of them gets it. A zero row count is how the loser finds out.
  @Query(r'''
UPDATE product_variants
SET inventory_quantity = inventory_quantity - CASE
      WHEN manage_inventory = 1 THEN $2 ELSE 0
    END
WHERE id = $1
  AND (manage_inventory = 0 OR allow_backorder = 1
       OR inventory_quantity >= $2)
''')
  Future<Result<ExecResult, SqlxError>> reserveStock(
    String variantId,
    int quantity,
  );

  /// Counts a redemption, so a limited promotion runs out.
  ///
  /// Incremented in SQL rather than read-then-written: two checkouts redeeming
  /// the last use of a code would otherwise both read the same count.
  @Query(r'''
UPDATE promotions SET usage_count = usage_count + 1 WHERE code = $1
''')
  Future<Result<ExecResult, SqlxError>> countRedemption(String code);

  /// Empties the cart once its lines have been copied onto the order.
  @Query(r'DELETE FROM line_items WHERE cart_id = $1')
  Future<Result<ExecResult, SqlxError>> clearCart(String cartId);

  /// Marks the cart terminal inside the same transaction as its order.
  @Query(r'''
UPDATE carts SET completed_at = $2 WHERE id = $1 AND completed_at IS NULL
''')
  Future<Result<ExecResult, SqlxError>> completeCart(
    String cartId,
    String completedAt,
  );
}
