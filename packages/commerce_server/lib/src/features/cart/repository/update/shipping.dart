import 'package:dust_dart/db.dart';

part 'shipping.g.dart';

/// Atomic writes that keep a cart's chosen delivery method eligible.
@SqlxDao()
abstract final class CartShippingRepository {
  /// Binds shipping writes to [db].
  const factory CartShippingRepository(Executor db) = _$CartShippingRepository;

  /// Chooses a delivery method only while every rule matches the current cart.
  @Query(r'''
WITH cart_value(item_total) AS (
  SELECT coalesce(sum(line.unit_amount * line.quantity), 0)
  FROM line_items line
  WHERE line.cart_id = $1
)
INSERT INTO cart_shipping_methods (cart_id, option_id, name, amount)
SELECT $1, $2, $3, $4
FROM cart_value
WHERE NOT EXISTS (
  SELECT 1
  FROM shipping_option_price_rules rule
  WHERE rule.shipping_option_id = $2
    AND rule.deleted_at IS NULL
    AND NOT (CASE rule.operator
      WHEN 'gt' THEN cart_value.item_total > rule.value
      WHEN 'gte' THEN cart_value.item_total >= rule.value
      WHEN 'lt' THEN cart_value.item_total < rule.value
      WHEN 'lte' THEN cart_value.item_total <= rule.value
      WHEN 'eq' THEN cart_value.item_total = rule.value
      ELSE FALSE
    END)
)
ON CONFLICT (cart_id) DO UPDATE
SET option_id = excluded.option_id,
    name = excluded.name,
    amount = excluded.amount
''')
  Future<Result<ExecResult, SqlxError>> setShippingMethod(
    String cartId,
    String optionId,
    String name,
    int amount,
  );

  /// Clears a chosen option when a line mutation stops satisfying its rules.
  @Query(r'''
WITH cart_value(item_total) AS (
  SELECT coalesce(sum(line.unit_amount * line.quantity), 0)
  FROM line_items line
  WHERE line.cart_id = $1
)
DELETE FROM cart_shipping_methods AS method
WHERE method.cart_id = $1
  AND EXISTS (
    SELECT 1
    FROM shipping_option_price_rules rule, cart_value
    WHERE rule.shipping_option_id = method.option_id
      AND rule.deleted_at IS NULL
      AND NOT (CASE rule.operator
        WHEN 'gt' THEN cart_value.item_total > rule.value
        WHEN 'gte' THEN cart_value.item_total >= rule.value
        WHEN 'lt' THEN cart_value.item_total < rule.value
        WHEN 'lte' THEN cart_value.item_total <= rule.value
        WHEN 'eq' THEN cart_value.item_total = rule.value
        ELSE FALSE
      END)
  )
''')
  Future<Result<ExecResult, SqlxError>> clearIneligibleMethod(String cartId);

  /// Clears a delivery quote when its cart changes selling region.
  @Query(r'DELETE FROM cart_shipping_methods WHERE cart_id = $1')
  Future<Result<ExecResult, SqlxError>> clearShippingMethod(String cartId);
}
