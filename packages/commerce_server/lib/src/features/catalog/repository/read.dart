import 'package:commerce_server/src/features/catalog/model.dart';
import 'package:commerce_server/src/features/catalog/sellable_variant.dart';
import 'package:dust_dart/db.dart';

part 'read.g.dart';

/// The catalogue's complete-response single-row reads.
@SqlxDao()
abstract final class CatalogReadRepository {
  /// Binds the queries to [db].
  const factory CatalogReadRepository(Executor db) = _$CatalogReadRepository;

  /// One published product with complete currency-scoped storefront data.
  @Query(r'''
SELECT product.id, product.title, product.handle, product.description,
       product.thumbnail, product.status,
       CASE WHEN collection.id IS NULL THEN 'null' ELSE json_build_object('id', collection.id, 'title', collection.title, 'handle', collection.handle) END AS collection,
       json_build_object('material', product.material, 'origin_country', product.origin_country, 'product_type', product_type.value,
         'weight', product.weight, 'length', product.length, 'width', product.width, 'height', product.height) AS details,
       coalesce((
         SELECT json_agg(dust_json_value(ordered.image_json))
         FROM (
           SELECT json_build_object('id', image.id, 'url', image.url, 'rank', image.rank) AS image_json
           FROM product_images image
           WHERE image.product_id = product.id AND image.deleted_at IS NULL
           ORDER BY image.rank, image.id
         ) ordered
       ), '[]') AS images,
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
       ), '[]') AS categories,
       coalesce((
         SELECT json_agg(dust_json_value(ordered.tag_json))
         FROM (
           SELECT json_build_object('id', tag.id, 'value', tag.value) AS tag_json
           FROM product_tag_products link
           JOIN product_tags tag ON tag.id = link.tag_id
           WHERE link.product_id = product.id AND tag.deleted_at IS NULL
           ORDER BY tag.value
         ) ordered
       ), '[]') AS tags,
       coalesce((
         SELECT json_agg(dust_json_value(ordered.option_json))
         FROM (
           SELECT json_build_object(
             'id', option.id, 'title', option.title,
             'values', dust_json_value(coalesce((
               SELECT json_agg(ordered_value.value)
               FROM (
                 SELECT option_value.value
                 FROM product_product_option_values availability
                 JOIN product_option_values option_value
                   ON option_value.id = availability.product_option_value_id
                 WHERE availability.product_product_option_id = link.id
                   AND option_value.deleted_at IS NULL
                   AND availability.deleted_at IS NULL
                 ORDER BY option_value.rank, option_value.id
               ) ordered_value
             ), '[]'))
           ) AS option_json
           FROM product_product_options link
           JOIN product_options option ON option.id = link.product_option_id
           WHERE link.product_id = product.id
             AND link.deleted_at IS NULL
             AND option.deleted_at IS NULL
           ORDER BY link.id
         ) ordered
       ), '[]') AS options,
       coalesce((
         SELECT json_agg(dust_json_value(ordered.variant_json))
         FROM (
           SELECT json_build_object(
             'id', variant.id, 'title', variant.title, 'sku', variant.sku,
             'inventory_quantity', variant.inventory_quantity,
             'manage_inventory', variant.manage_inventory,
             'allow_backorder', variant.allow_backorder, 'amount', price.amount,
             'currency_code', price.currency_code,
             'original_amount', original_price.amount,
             'option_values', dust_json_value(coalesce((
               SELECT jsonb_object_agg(choice.option_id, option_value.value)
               FROM variant_option_values choice
               JOIN product_option_values option_value
                 ON option_value.id = choice.option_value_id
                AND option_value.option_id = choice.option_id
               WHERE choice.variant_id = variant.id
                 AND option_value.deleted_at IS NULL
             ), '{}')),
             'images', dust_json_value(coalesce((
               SELECT json_agg(dust_json_value(ordered_image.image_json))
               FROM (
                 SELECT json_build_object('id', image.id, 'url', image.url, 'rank', image.rank) AS image_json
                 FROM product_image_variants image_variant
                 JOIN product_images image ON image.id = image_variant.image_id
                 WHERE image_variant.variant_id = variant.id
                   AND image.deleted_at IS NULL
                 ORDER BY image.rank, image.id
               ) ordered_image
             ), '[]'))
           ) AS variant_json
           FROM product_variants variant
           JOIN variant_prices price ON price.variant_id = variant.id
           LEFT JOIN variant_original_prices original_price
             ON original_price.variant_id = variant.id
            AND original_price.currency_code = price.currency_code
           WHERE variant.product_id = product.id
             AND variant.deleted_at IS NULL
             AND price.currency_code = $2
           ORDER BY variant.id
         ) ordered
       ), '[]') AS variants
FROM products product
LEFT JOIN product_collections collection
  ON collection.id = product.collection_id AND collection.deleted_at IS NULL
LEFT JOIN product_types product_type
  ON product_type.id = product.type_id AND product_type.deleted_at IS NULL
WHERE product.handle = $1
  AND product.status = 'published'
  AND product.deleted_at IS NULL
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
''')
  Future<Result<ProductResponse?, SqlxError>> findByHandle(
    String handle,
    String currencyCode,
  );

  /// One variant only when its product is still sold through the cart channel.
  @Query(r'''
SELECT v.id, v.product_id, v.title, v.sku, v.inventory_quantity,
       v.manage_inventory, v.allow_backorder,
       p.currency_code, p.amount, product.title AS product_title,
       product.handle AS product_handle, product.thumbnail
FROM product_variants v
JOIN variant_prices p ON p.variant_id = v.id
JOIN products product ON product.id = v.product_id
WHERE v.id = $1 AND p.currency_code = $2
  AND v.deleted_at IS NULL
  AND product.deleted_at IS NULL
  AND product.status = 'published'
  AND (NOT EXISTS (SELECT 1 FROM cart_sales_channels WHERE cart_id = $3)
       OR EXISTS (
    SELECT 1 FROM cart_sales_channels cart_channel
    JOIN product_sales_channels product_channel
      ON product_channel.sales_channel_id = cart_channel.sales_channel_id
    JOIN sales_channels channel ON channel.id = cart_channel.sales_channel_id
    WHERE cart_channel.cart_id = $3
      AND product_channel.product_id = product.id
      AND product_channel.deleted_at IS NULL
      AND channel.is_disabled = 0
      AND channel.deleted_at IS NULL
  ))
''')
  Future<Result<SellableVariant?, SqlxError>> findVariantForCart(
    String variantId,
    String currencyCode,
    String cartId,
  );
}
