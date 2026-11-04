import 'package:commerce_server/src/features/catalog/model.dart';
import 'package:dust_dart/db.dart';

part 'products.g.dart';

/// The catalogue's complete-response list queries.
@SqlxDao()
abstract final class CatalogListRepository {
  /// Binds the queries to [db].
  const factory CatalogListRepository(Executor db) = _$CatalogListRepository;

  /// Published products with complete currency-scoped storefront data.
  @Query(r'''
SELECT product.id, product.title, product.handle, product.description,
       product.thumbnail, product.status,
       (CASE WHEN collection.id IS NULL THEN 'null' ELSE json_build_object('id', collection.id, 'title', collection.title, 'handle', collection.handle) END)::text AS collection,
       json_build_object('material', product.material, 'origin_country', product.origin_country, 'product_type', product_type.value,
         'weight', product.weight, 'length', product.length, 'width', product.width, 'height', product.height)::text AS details,
       coalesce((
         SELECT json_agg(dust_json_value(ordered.image_json))
         FROM (
           SELECT json_build_object('id', image.id, 'url', image.url, 'rank', image.rank) AS image_json
           FROM product_images image
           WHERE image.product_id = product.id AND image.deleted_at IS NULL
           ORDER BY image.rank, image.id
         ) ordered
       ), '[]')::text AS images,
       coalesce((
         SELECT json_agg(dust_json_value(ordered.category_json))
         FROM (
           SELECT json_build_object('id', category.id, 'name', category.name,
             'description', category.description, 'handle', category.handle,
             'parent_id', category.parent_category_id) AS category_json
           FROM product_category_products link
           JOIN product_categories category ON category.id = link.category_id
           WHERE link.product_id = product.id
             AND category.is_active = 1
             AND category.deleted_at IS NULL
           ORDER BY link.rank, category.handle
         ) ordered
       ), '[]')::text AS categories,
       coalesce((
         SELECT json_agg(dust_json_value(ordered.tag_json))
         FROM (
           SELECT json_build_object('id', tag.id, 'value', tag.value) AS tag_json
           FROM product_tag_products link
           JOIN product_tags tag ON tag.id = link.tag_id
           WHERE link.product_id = product.id AND tag.deleted_at IS NULL
           ORDER BY tag.value
         ) ordered
       ), '[]')::text AS tags,
       coalesce((
         SELECT json_agg(dust_json_value(ordered.option_json))
         FROM (
          SELECT json_build_object('id', option.id, 'title', option.title,
            'values', dust_json_value(coalesce((
               SELECT json_agg(ordered_value.value)
               FROM (
                SELECT option_value.value FROM product_product_option_values availability
                JOIN product_option_values option_value ON option_value.id = availability.product_option_value_id
                WHERE availability.product_product_option_id = link.id AND option_value.deleted_at IS NULL
                  AND availability.deleted_at IS NULL ORDER BY option_value.rank, option_value.id
               ) ordered_value
             ), '[]'))
           ) AS option_json
           FROM product_product_options link
           JOIN product_options option ON option.id = link.product_option_id
           WHERE link.product_id = product.id AND link.deleted_at IS NULL AND option.deleted_at IS NULL
           ORDER BY link.id
         ) ordered
       ), '[]')::text AS options,
       coalesce((
         SELECT json_agg(dust_json_value(ordered.variant_json))
         FROM (
          SELECT json_build_object('id', variant.id, 'title', variant.title, 'sku', variant.sku,
             'inventory_quantity', variant.inventory_quantity, 'manage_inventory', variant.manage_inventory,
             'allow_backorder', variant.allow_backorder, 'amount', price.amount,
             'currency_code', price.currency_code,
             'original_amount', original_price.amount,
             'option_values', dust_json_value(coalesce((
              SELECT jsonb_object_agg(choice.option_id, option_value.value) FROM variant_option_values choice
              JOIN product_option_values option_value ON option_value.id = choice.option_value_id AND option_value.option_id = choice.option_id
              WHERE choice.variant_id = variant.id AND option_value.deleted_at IS NULL
             ), '{}')),
             'images', dust_json_value(coalesce((
               SELECT json_agg(dust_json_value(ordered_image.image_json))
               FROM (
                SELECT json_build_object('id', image.id, 'url', image.url, 'rank', image.rank) AS image_json FROM product_image_variants image_variant
                JOIN product_images image ON image.id = image_variant.image_id WHERE image_variant.variant_id = variant.id AND image.deleted_at IS NULL
                 ORDER BY image.rank, image.id
               ) ordered_image
             ), '[]'))
           ) AS variant_json
           FROM product_variants variant
           JOIN variant_prices price ON price.variant_id = variant.id
           LEFT JOIN variant_original_prices original_price ON original_price.variant_id = variant.id AND original_price.currency_code = price.currency_code
           WHERE variant.product_id = product.id
             AND variant.deleted_at IS NULL
             AND price.currency_code = $1
           ORDER BY variant.id
         ) ordered
       ), '[]')::text AS variants
FROM products product
JOIN (
  SELECT variant.product_id, min(price.amount) AS min_price
  FROM product_variants variant
  JOIN variant_prices price ON price.variant_id = variant.id
  WHERE variant.deleted_at IS NULL AND price.currency_code = $1
  GROUP BY variant.product_id
) priced ON priced.product_id = product.id
LEFT JOIN product_collections collection ON collection.id = product.collection_id AND collection.deleted_at IS NULL
LEFT JOIN product_types product_type ON product_type.id = product.type_id AND product_type.deleted_at IS NULL
WHERE product.status = 'published' AND product.deleted_at IS NULL
  AND (NOT EXISTS (SELECT 1 FROM sales_channels channel WHERE channel.is_disabled = 0 AND channel.deleted_at IS NULL) OR EXISTS (
    SELECT 1 FROM product_sales_channels channel_link
    WHERE channel_link.product_id = product.id AND channel_link.deleted_at IS NULL
      AND channel_link.sales_channel_id = (
        SELECT id FROM sales_channels WHERE is_disabled = 0 AND deleted_at IS NULL ORDER BY id LIMIT 1
      )
  ))
  AND (CAST($4 AS TEXT) IS NULL OR lower(product.title) LIKE '%' || lower($4) || '%' OR lower(product.handle) LIKE '%' || lower($4) || '%')
  AND (CAST($5 AS TEXT) IS NULL OR collection.handle = $5)
  AND (jsonb_array_length($6::jsonb) = 0 OR EXISTS (
    SELECT 1 FROM product_category_products filter_link
    JOIN product_categories filter_category ON filter_category.id = filter_link.category_id
      WHERE filter_link.product_id = product.id AND filter_category.handle IN (
        SELECT value FROM jsonb_array_elements_text($6::jsonb)
      )
      AND filter_category.is_active = 1 AND filter_category.deleted_at IS NULL
  ))
  AND (jsonb_array_length($7::jsonb) = 0 OR EXISTS (
    SELECT 1 FROM product_tag_products filter_link
    JOIN product_tags filter_tag ON filter_tag.id = filter_link.tag_id
      WHERE filter_link.product_id = product.id AND lower(filter_tag.value) IN (
        SELECT lower(value) FROM jsonb_array_elements_text($7::jsonb)
      )
      AND filter_tag.deleted_at IS NULL
  ))
  AND (CAST($9 AS INTEGER) IS NULL OR priced.min_price >= $9)
  AND (CAST($10 AS INTEGER) IS NULL OR priced.min_price <= $10)
  AND ($11 = 0 OR EXISTS (
    SELECT 1 FROM product_variants sale_variant
    JOIN variant_prices sale_price ON sale_price.variant_id = sale_variant.id
    JOIN variant_original_prices sale_original ON sale_original.variant_id = sale_variant.id AND sale_original.currency_code = sale_price.currency_code
    WHERE sale_variant.product_id = product.id AND sale_variant.deleted_at IS NULL
      AND sale_price.currency_code = $1 AND sale_original.amount > sale_price.amount
  ))
  AND NOT EXISTS (
    SELECT 1 FROM jsonb_array_elements_text($12::jsonb) selected_option_value(value)
    WHERE NOT EXISTS (
      SELECT 1 FROM product_variants filter_variant
      JOIN variant_prices filter_price ON filter_price.variant_id = filter_variant.id
      JOIN variant_option_values filter_choice ON filter_choice.variant_id = filter_variant.id
      JOIN product_options filter_option ON filter_option.id = filter_choice.option_id
      JOIN product_product_options filter_product_option ON filter_product_option.product_id = product.id AND filter_product_option.product_option_id = filter_option.id
      JOIN product_option_values filter_value ON filter_value.id = filter_choice.option_value_id AND filter_value.option_id = filter_choice.option_id
      WHERE filter_variant.product_id = product.id AND filter_variant.deleted_at IS NULL
        AND filter_price.currency_code = $1 AND filter_option.deleted_at IS NULL
        AND filter_product_option.deleted_at IS NULL AND filter_value.deleted_at IS NULL
        AND filter_choice.option_value_id = selected_option_value.value
    )
  )
ORDER BY
  CASE WHEN $8 IN ('created_at', 'relevance') THEN product.created_at END DESC,
  CASE WHEN $8 = 'price_asc' THEN priced.min_price END, CASE WHEN $8 = 'price_desc' THEN priced.min_price END DESC,
  CASE WHEN $8 = 'title_asc' THEN lower(product.title) END, CASE WHEN $8 = 'title_desc' THEN lower(product.title) END DESC,
  product.handle
LIMIT $2 OFFSET $3
''')
  Future<Result<List<ProductResponse>, SqlxError>> listPublished(
    String currencyCode,
    int limit,
    int offset,
    String? query,
    String? collectionHandle,
    String categoryHandlesJson,
    String labelValuesJson,
    String sortBy,
    int? minPrice,
    int? maxPrice,
    int onSale,
    String optionValueIdsJson,
  );
}
