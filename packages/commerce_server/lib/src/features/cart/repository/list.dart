import 'package:commerce_server/src/features/cart/model/shipping.dart';
import 'package:dust_dart/db.dart';

part 'list.g.dart';

/// The cart's list queries.
@SqlxDao()
abstract final class CartListRepository {
  /// Binds the queries to [db].
  const factory CartListRepository(Executor db) = _$CartListRepository;

  /// The delivery options [regionId] offers, cheapest first.
  ///
  /// Scoped to the region in SQL. An option belonging to another region cannot
  /// be offered, and therefore cannot be chosen, without the handler having to
  /// remember to check.
  @Query(r'''
SELECT option.id AS option_id, option.name,
       json_build_object(
         'amount', option.amount,
         'currency_code', option.currency_code
       ) AS amount,
       coalesce((
         SELECT json_agg(dust_json_value(ordered.rule_json))
         FROM (
           SELECT json_build_object(
             'attribute', rule.attribute,
             'operator', rule.operator,
             'value', rule.value
           ) AS rule_json
           FROM shipping_option_price_rules rule
           WHERE rule.shipping_option_id = option.id
             AND rule.deleted_at IS NULL
           ORDER BY rule.id
         ) ordered
       ), '[]') AS price_rules
FROM shipping_options option
WHERE option.region_id = $1 AND option.deleted_at IS NULL
ORDER BY option.amount, option.id
''')
  Future<Result<List<ShippingOptionResponse>, SqlxError>> shippingOptionsOf(
    String regionId,
  );

  /// One option, checked against the region that is allowed to use it.
  @Query(r'''
SELECT option.id AS option_id, option.name,
       json_build_object(
         'amount', option.amount,
         'currency_code', option.currency_code
       ) AS amount,
       coalesce((
         SELECT json_agg(dust_json_value(ordered.rule_json))
         FROM (
           SELECT json_build_object(
             'attribute', rule.attribute,
             'operator', rule.operator,
             'value', rule.value
           ) AS rule_json
           FROM shipping_option_price_rules rule
           WHERE rule.shipping_option_id = option.id
             AND rule.deleted_at IS NULL
           ORDER BY rule.id
         ) ordered
       ), '[]') AS price_rules
FROM shipping_options option
WHERE option.id = $1 AND option.region_id = $2
  AND option.deleted_at IS NULL
''')
  Future<Result<ShippingOptionResponse?, SqlxError>> shippingOptionFor(
    String optionId,
    String regionId,
  );
}
