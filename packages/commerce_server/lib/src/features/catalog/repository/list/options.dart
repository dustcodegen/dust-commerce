import 'package:commerce_server/src/features/catalog/option_filter_response.dart';
import 'package:dust_dart/db.dart';

part 'options.g.dart';

/// Store-wide product-option refinement queries.
@SqlxDao()
abstract final class CatalogOptionRepository {
  /// Binds the query to [db].
  const factory CatalogOptionRepository(DatabaseExecutor db) =
      _$CatalogOptionRepository;

  /// Active options and values belonging to published products.
  @Query(r'''
SELECT option.id, option.title,
       coalesce((
         SELECT json_group_array(json(ordered.value_json))
         FROM (
           SELECT json_object('id', available.id,
                              'value', available.value,
                              'count', available.count) AS value_json
           FROM (
             SELECT DISTINCT option_value.id, option_value.value,
                             option_value.rank,
                             count(DISTINCT product.id) AS count
             FROM product_option_values option_value
             JOIN product_product_option_values availability
               ON availability.product_option_value_id = option_value.id
             JOIN product_product_options product_option
               ON product_option.id = availability.product_product_option_id
             JOIN products product ON product.id = product_option.product_id
             WHERE option_value.option_id = option.id
               AND option_value.deleted_at IS NULL
               AND availability.deleted_at IS NULL
               AND product_option.deleted_at IS NULL
               AND product.status = 'published'
               AND product.deleted_at IS NULL
             GROUP BY option_value.id, option_value.value, option_value.rank
           ) available
           ORDER BY available.rank, available.id
         ) ordered
       ), '[]') AS "values"
FROM product_options option
WHERE option.deleted_at IS NULL
  AND EXISTS (
    SELECT 1
    FROM product_product_options product_option
    JOIN products product ON product.id = product_option.product_id
    WHERE product_option.product_option_id = option.id
      AND product_option.deleted_at IS NULL
      AND product.status = 'published'
      AND product.deleted_at IS NULL
  )
ORDER BY option.title, option.id
LIMIT $1 OFFSET $2
''')
  Future<Result<List<ProductOptionFilterResponse>, SqlxError>> list(
    int limit,
    int offset,
  );
}
