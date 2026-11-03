import 'package:commerce_server/src/features/admin/product_detail_model.dart';
import 'package:dust_dart/db.dart';

part 'product.g.dart';

/// Product detail reads live under the read operation without an ORM layer.
@SqlxDao()
abstract final class AdminProductReadRepository {
  /// Binds one-shot product detail reads to [db].
  const factory AdminProductReadRepository(Executor db) =
      _$AdminProductReadRepository;

  /// Reads every currently modeled Medusa detail section in one SQL row.
  @Query(r'''
SELECT product.id, product.title, product.subtitle, product.handle,
       product.description, product.discountable = 1 AS discountable,
       product.thumbnail,
       product.material, product.origin_country,
       product.type_id AS product_type_id,
       product_type.value AS product_type,
       product.weight, product.length, product.width,
       product.height, product.status, collection.title AS collection_title,
       coalesce((
         SELECT json_build_object(
           'id', profile.id,
           'name', profile.name,
           'type', profile.type,
           'created_at', profile.created_at,
           'updated_at', profile.updated_at
         )
         FROM product_shipping_profile link
         JOIN shipping_profile profile
           ON profile.id = link.shipping_profile_id
         WHERE link.product_id = product.id
           AND link.deleted_at IS NULL
           AND profile.deleted_at IS NULL
         LIMIT 1
       ), 'null')::text AS shipping_profile,
       coalesce((
         SELECT json_agg(dust_json_value(ordered.image_json))
         FROM (
           SELECT json_build_object(
             'id', image.id,
             'url', image.url,
             'variant_ids', dust_json_value(coalesce((
               SELECT json_agg(link.variant_id ORDER BY link.variant_id)
               FROM product_image_variants link
               WHERE link.image_id = image.id
             ), '[]'))
           ) AS image_json
           FROM product_images image
           WHERE image.product_id = product.id AND image.deleted_at IS NULL
           ORDER BY image.rank, image.id
         ) ordered
       ), '[]')::text AS images,
       coalesce((
         SELECT json_agg(dust_json_value(ordered.option_json))
         FROM (
           SELECT json_build_object(
             'id', option.id, 'title', option.title,
             'values', dust_json_value(coalesce((
               SELECT json_agg(value_ordered.value)
               FROM (
                 SELECT value.value
                 FROM product_product_option_values availability
                 JOIN product_option_values value
                   ON value.id = availability.product_option_value_id
                 WHERE availability.product_product_option_id = link.id
                   AND value.deleted_at IS NULL
                   AND availability.deleted_at IS NULL
                 ORDER BY value.rank, value.id
               ) value_ordered
             ), '[]'))
           ) AS option_json
           FROM product_product_options link
           JOIN product_options option ON option.id = link.product_option_id
           WHERE link.product_id = product.id
             AND link.deleted_at IS NULL
             AND option.deleted_at IS NULL
           ORDER BY link.created_at, link.id
         ) ordered
       ), '[]')::text AS options,
       coalesce((
         SELECT json_agg(dust_json_value(ordered.variant_json))
         FROM (
           SELECT json_build_object(
             'id', variant.id, 'title', variant.title, 'sku', variant.sku,
             'material', variant.material, 'ean', variant.ean,
             'upc', variant.upc,
             'barcode', variant.barcode,
             'weight', variant.weight, 'width', variant.width,
             'length', variant.length, 'height', variant.height,
             'mid_code', variant.mid_code, 'hs_code', variant.hs_code,
             'origin_country', variant.origin_country,
             'inventory_quantity', variant.inventory_quantity,
             'manage_inventory', dust_json_value(iif(variant.manage_inventory = 1,
                                          'true', 'false')),
             'allow_backorder', dust_json_value(iif(variant.allow_backorder = 1,
                                         'true', 'false')),
             'prices', dust_json_value(coalesce((
               SELECT json_agg(dust_json_value(price_ordered.price_json))
               FROM (
                 SELECT json_build_object(
                   'currency_code', price.currency_code,
                   'amount', price.amount
                 ) AS price_json
                 FROM variant_prices price
                 WHERE price.variant_id = variant.id
                 ORDER BY price.currency_code
               ) price_ordered
             ), '[]')),
             'option_values', dust_json_value(coalesce((
               SELECT jsonb_object_agg(choice.option_id, value.value)
               FROM variant_option_values choice
               JOIN product_option_values value
                 ON value.id = choice.option_value_id
                AND value.option_id = choice.option_id
               WHERE choice.variant_id = variant.id
                 AND value.deleted_at IS NULL
             ), '{}'))
           ) AS variant_json
           FROM product_variants variant
           WHERE variant.product_id = product.id
             AND variant.deleted_at IS NULL
           ORDER BY variant.id
         ) ordered
       ), '[]')::text AS variants,
       coalesce((
         SELECT array_agg(category.name ORDER BY link.rank, category.name)
         FROM product_category_products link
         JOIN product_categories category ON category.id = link.category_id
         WHERE link.product_id = product.id
           AND category.deleted_at IS NULL
       ), ARRAY[]::text[]) AS categories,
       coalesce((
         SELECT array_agg(tag.value ORDER BY tag.value)
         FROM product_tag_products link
         JOIN product_tags tag ON tag.id = link.tag_id
         WHERE link.product_id = product.id AND tag.deleted_at IS NULL
       ), ARRAY[]::text[]) AS tags
FROM products product
LEFT JOIN product_collections collection
  ON collection.id = product.collection_id AND collection.deleted_at IS NULL
LEFT JOIN product_types product_type
  ON product_type.id = product.type_id AND product_type.deleted_at IS NULL
WHERE product.id = $1 AND product.deleted_at IS NULL
''')
  Future<Result<AdminProductDetailResponse?, SqlxError>> findById(String id);
}
