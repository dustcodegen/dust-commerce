import 'package:dust_dart/db.dart';

part 'count.g.dart';

/// Count query paired with the paged catalogue response.
@SqlxDao()
abstract final class CatalogCountRepository {
  /// Binds the query to [db].
  const factory CatalogCountRepository(Executor db) = _$CatalogCountRepository;

  /// How many published products match the active refinements.
  @Query(r'''
SELECT COUNT(*) AS total
FROM products product
JOIN (
  SELECT variant.product_id, min(price.amount) AS min_price
  FROM product_variants variant
  JOIN variant_prices price ON price.variant_id = variant.id
  WHERE variant.deleted_at IS NULL AND price.currency_code = $1
  GROUP BY variant.product_id
) priced ON priced.product_id = product.id
LEFT JOIN product_collections collection
  ON collection.id = product.collection_id AND collection.deleted_at IS NULL
WHERE product.status = 'published' AND product.deleted_at IS NULL
  AND (NOT EXISTS (SELECT 1 FROM sales_channels channel WHERE channel.is_disabled = 0 AND channel.deleted_at IS NULL)
       OR EXISTS (
         SELECT 1 FROM product_sales_channels channel_link
         WHERE channel_link.product_id = product.id AND channel_link.deleted_at IS NULL
           AND channel_link.sales_channel_id = (
             SELECT id FROM sales_channels
             WHERE is_disabled = 0 AND deleted_at IS NULL
             ORDER BY id LIMIT 1
           )
       ))
  AND (CAST($2 AS TEXT) IS NULL OR lower(product.title) LIKE '%' || lower($2) || '%'
       OR lower(product.handle) LIKE '%' || lower($2) || '%')
  AND (CAST($3 AS TEXT) IS NULL OR collection.handle = $3)
  AND (jsonb_array_length($4::jsonb) = 0 OR EXISTS (
    SELECT 1
    FROM product_category_products filter_link
    JOIN product_categories filter_category
      ON filter_category.id = filter_link.category_id
    WHERE filter_link.product_id = product.id
      AND filter_category.handle IN (
        SELECT value FROM jsonb_array_elements_text($4::jsonb)
      )
      AND filter_category.is_active = 1
      AND filter_category.deleted_at IS NULL
  ))
  AND (jsonb_array_length($5::jsonb) = 0 OR EXISTS (
    SELECT 1
    FROM product_tag_products filter_link
    JOIN product_tags filter_tag ON filter_tag.id = filter_link.tag_id
    WHERE filter_link.product_id = product.id
      AND lower(filter_tag.value) IN (
        SELECT lower(value) FROM jsonb_array_elements_text($5::jsonb)
      )
      AND filter_tag.deleted_at IS NULL
  ))
  AND (CAST($6 AS INTEGER) IS NULL OR priced.min_price >= $6)
  AND (CAST($7 AS INTEGER) IS NULL OR priced.min_price <= $7)
  AND ($8 = 0 OR EXISTS (
    SELECT 1
    FROM product_variants sale_variant
    JOIN variant_prices sale_price
      ON sale_price.variant_id = sale_variant.id
    JOIN variant_original_prices sale_original
      ON sale_original.variant_id = sale_variant.id
     AND sale_original.currency_code = sale_price.currency_code
    WHERE sale_variant.product_id = product.id
      AND sale_variant.deleted_at IS NULL
      AND sale_price.currency_code = $1
      AND sale_original.amount > sale_price.amount
  ))
  AND NOT EXISTS (
    SELECT 1
    FROM jsonb_array_elements_text($9::jsonb) selected_option_value(value)
    WHERE NOT EXISTS (
      SELECT 1
      FROM product_variants filter_variant
      JOIN variant_prices filter_price
        ON filter_price.variant_id = filter_variant.id
      JOIN variant_option_values filter_choice
        ON filter_choice.variant_id = filter_variant.id
      JOIN product_options filter_option
        ON filter_option.id = filter_choice.option_id
      JOIN product_product_options filter_product_option
        ON filter_product_option.product_id = product.id
       AND filter_product_option.product_option_id = filter_option.id
      JOIN product_option_values filter_value
        ON filter_value.id = filter_choice.option_value_id
       AND filter_value.option_id = filter_choice.option_id
      WHERE filter_variant.product_id = product.id
        AND filter_variant.deleted_at IS NULL
        AND filter_price.currency_code = $1
        AND filter_option.deleted_at IS NULL
        AND filter_product_option.deleted_at IS NULL
        AND filter_value.deleted_at IS NULL
        AND filter_choice.option_value_id = selected_option_value.value
    )
  )
''')
  Future<Result<int, SqlxError>> countPublished(
    String currencyCode,
    String? query,
    String? collectionHandle,
    String categoryHandlesJson,
    String labelValuesJson,
    int? minPrice,
    int? maxPrice,
    int onSale,
    String optionValueIdsJson,
  );
}
