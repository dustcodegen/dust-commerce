import 'package:dust_dart/db.dart';

part 'cart.g.dart';

/// The writes that change what a cart holds.
@SqlxDao()
abstract final class CartUpdateRepository {
  /// Binds the queries to [db].
  const factory CartUpdateRepository(Executor db) = _$CartUpdateRepository;

  /// Adds a line, with the price snapshot taken by the caller.
  @Query(r'''
INSERT INTO line_items (id, cart_id, variant_id, product_id, product_handle,
                        thumbnail, title, variant_title, unit_amount,
                        currency_code, quantity)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
''')
  Future<Result<ExecResult, SqlxError>> insertLine(
    String id,
    String cartId,
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

  /// Sets the quantity of an existing line, keeping its price snapshot.
  @Query(
    r'UPDATE line_items SET quantity = $2 WHERE id = $1 AND cart_id = $3',
  )
  Future<Result<ExecResult, SqlxError>> setLineQuantity(
    String lineId,
    int quantity,
    String cartId,
  );

  /// Removes a line.
  @Query(r'DELETE FROM line_items WHERE id = $1 AND cart_id = $2')
  Future<Result<ExecResult, SqlxError>> deleteLine(
    String lineId,
    String cartId,
  );

  /// Applies a promotion, replacing any earlier one.
  ///
  /// One promotion per cart, so this is an upsert on the cart id. Stacking is
  /// a decision with rules of its own — which combine, which exclude — and a
  /// schema that allowed two without those rules would be a bug waiting.
  @Query(r'''
INSERT INTO cart_promotions
  (cart_id, promotion_id, code, type, value, currency_code, amount)
VALUES ($1, $2, $3, $4, $5, $6, $7)
ON CONFLICT (cart_id) DO UPDATE
SET promotion_id = excluded.promotion_id,
    code = excluded.code,
    type = excluded.type,
    value = excluded.value,
    currency_code = excluded.currency_code,
    amount = excluded.amount
''')
  Future<Result<ExecResult, SqlxError>> setPromotion(
    String cartId,
    String promotionId,
    String code,
    String type,
    int value,
    String? currencyCode,
    int amount,
  );

  /// Refreshes the snapshotted amount after the cart's goods change.
  @Query(r'''
UPDATE cart_promotions SET amount = $2 WHERE cart_id = $1
''')
  Future<Result<ExecResult, SqlxError>> updatePromotionAmount(
    String cartId,
    int amount,
  );

  /// Removes whatever promotion the cart had.
  @Query(r'DELETE FROM cart_promotions WHERE cart_id = $1')
  Future<Result<ExecResult, SqlxError>> clearPromotion(String cartId);

  /// Records the email a guest checkout collected.
  @Query(r'''
UPDATE carts SET email = $2
WHERE id = $1 AND completed_at IS NULL AND deleted_at IS NULL
''')
  Future<Result<ExecResult, SqlxError>> setCartEmail(
    String cartId,
    String email,
  );

  /// Claims an active guest cart for one authenticated customer.
  ///
  /// Matching the same customer makes retries safe after a response is lost.
  /// A cart owned by somebody else, completed, or deleted matches no rows.
  @Query(r'''
UPDATE carts
SET customer_id = $2, email = $3
WHERE id = $1
  AND (customer_id IS NULL OR customer_id = $2)
  AND completed_at IS NULL
  AND deleted_at IS NULL
''')
  Future<Result<ExecResult, SqlxError>> claimCart(
    String cartId,
    String customerId,
    String email,
  );

  /// Counts cart lines that have no price in [currencyCode].
  @Query(r'''
SELECT count(*)
FROM line_items line
WHERE line.cart_id = $1
  AND NOT EXISTS (
    SELECT 1
    FROM variant_prices price
    WHERE price.variant_id = line.variant_id
      AND price.currency_code = $2
  )
''')
  Future<Result<int, SqlxError>> countLinesWithoutPrice(
    String cartId,
    String currencyCode,
  );

  /// Reprices every line from the authoritative regional variant price.
  @Query(r'''
UPDATE line_items AS line
SET unit_amount = (
      SELECT price.amount
      FROM variant_prices price
      WHERE price.variant_id = line.variant_id
        AND price.currency_code = $2
    ),
    currency_code = $2
WHERE line.cart_id = $1
''')
  Future<Result<ExecResult, SqlxError>> repriceLines(
    String cartId,
    String currencyCode,
  );

  /// Makes [regionId] govern an active cart.
  @Query(r'''
UPDATE carts
SET region_id = $2
WHERE id = $1 AND completed_at IS NULL AND deleted_at IS NULL
''')
  Future<Result<ExecResult, SqlxError>> setRegion(
    String cartId,
    String regionId,
  );
}
