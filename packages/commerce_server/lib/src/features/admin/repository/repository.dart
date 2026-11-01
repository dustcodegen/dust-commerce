/// Admin persistence operations.
library;

import 'package:commerce_server/src/features/admin/product_option_model.dart';
import 'package:dust_dart/db.dart';

export 'create.dart';
export 'delete.dart';
export 'delete/product.dart';
export 'delete/product_option.dart';
export 'export.dart';
export 'image_variants.dart';
export 'create/import.dart';
export 'create/import_confirm.dart';
export 'create/import_product.dart';
export 'create/import_relations.dart';
export 'create/import_variant.dart';
export 'list.dart';
export 'media.dart';
export 'product_create.dart';
export 'read.dart';
export 'update.dart';
export 'update/option.dart';
export 'update/price.dart';
export 'update/stock.dart';
export 'update_variant.dart';

part 'repository.g.dart';

/// Global product-option persistence behind protected merchant routes.
@SqlxDao()
abstract final class AdminProductOptionRepository {
  /// Binds product-option statements to [db].
  const factory AdminProductOptionRepository(Executor db) =
      _$AdminProductOptionRepository;

  /// Creates a global option unless its active title is already owned.
  @Query(r'''
INSERT INTO product_options (id, title, is_exclusive)
SELECT $1, trim($2), 0
WHERE NOT EXISTS (
  SELECT 1 FROM product_options
  WHERE title = trim($2) AND is_exclusive = 0 AND deleted_at IS NULL
)
''')
  Future<Result<ExecResult, SqlxError>> insert(String id, String title);

  /// Lists global options with the columns used by Medusa's table.
  @Query(r'''
SELECT option.id, option.title, option.is_exclusive,
       (SELECT count(*) FROM product_option_values value
        WHERE value.option_id = option.id AND value.deleted_at IS NULL)
         AS value_count
FROM product_options option
WHERE option.deleted_at IS NULL AND option.is_exclusive = 0
  AND ($1 = '' OR lower(option.title) LIKE '%' || lower($1) || '%')
ORDER BY option.created_at DESC, option.id
LIMIT $2 OFFSET $3
''')
  Future<Result<List<AdminProductOptionSummaryResponse>, SqlxError>> list(
    String query,
    int limit,
    int offset,
  );

  /// Counts global options matching the same title query.
  @Query(r'''
SELECT count(*)
FROM product_options option
WHERE option.deleted_at IS NULL AND option.is_exclusive = 0
  AND ($1 = '' OR lower(option.title) LIKE '%' || lower($1) || '%')
''')
  Future<Result<int, SqlxError>> count(String query);

  /// Reads one complete active product option by stable identifier.
  @Query(r'''
SELECT option.id, option.title, option.is_exclusive,
       coalesce((
         SELECT json_agg(dust_json_value(ordered.value_json))
         FROM (
           SELECT json_build_object('id', value.id, 'value', value.value,
                              'rank', value.rank) AS value_json
           FROM product_option_values value
           WHERE value.option_id = option.id AND value.deleted_at IS NULL
           ORDER BY value.rank, value.id
         ) ordered
       ), '[]') AS "values",
       coalesce((
         SELECT json_agg(dust_json_value(ordered.product_json))
         FROM (
           SELECT json_build_object(
             'id', product.id, 'title', product.title,
             'thumbnail', coalesce(product.thumbnail, ''),
             'collection_title', coalesce(collection.title, ''),
             'sales_channels', dust_json_value(coalesce((
               SELECT json_agg(dust_json_value(ordered_channel.channel_json))
               FROM (
                 SELECT json_build_object('id', channel.id, 'name', channel.name)
                          AS channel_json
                 FROM product_sales_channels channel_link
                 JOIN sales_channels channel
                   ON channel.id = channel_link.sales_channel_id
                 WHERE channel_link.product_id = product.id
                   AND channel_link.deleted_at IS NULL
                   AND channel.deleted_at IS NULL
                 ORDER BY lower(channel.name), channel.id
               ) ordered_channel
             ), '[]')), 'status', product.status,
             'variant_count', (SELECT count(*) FROM product_variants variant
               WHERE variant.product_id = product.id
                 AND variant.deleted_at IS NULL)
           ) AS product_json
           FROM product_product_options link
           JOIN products product ON product.id = link.product_id
           LEFT JOIN product_collections collection
             ON collection.id = product.collection_id
            AND collection.deleted_at IS NULL
           WHERE link.product_option_id = option.id
             AND link.deleted_at IS NULL AND product.deleted_at IS NULL
           ORDER BY product.created_at DESC, product.id
         ) ordered
       ), '[]') AS products
FROM product_options option
WHERE option.id = $1 AND option.deleted_at IS NULL
''')
  Future<Result<AdminProductOptionDetailResponse?, SqlxError>> findById(
    String id,
  );
}
