import 'package:commerce_server/src/features/admin/product_import_model.dart';
import 'package:dust_dart/db.dart';

part 'import_relations.g.dart';

/// Child-graph writes used only inside a product-import transaction.
@SqlxDao()
abstract final class AdminProductImportRelationRepository {
  /// Binds imported child-graph writes to [db].
  const factory AdminProductImportRelationRepository(Executor db) =
      _$AdminProductImportRelationRepository;

  /// Moves active ranks out of the way and retires the previous gallery.
  @Query(r'''
UPDATE product_images SET
  rank = rank + (SELECT coalesce(max(rank), -1) + 1
                 FROM product_images WHERE product_id = $1),
  deleted_at = strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
WHERE product_id = $1 AND deleted_at IS NULL
''')
  Future<Result<ExecResult, SqlxError>> retireImages(String productId);

  /// Inserts one externally hosted product image in CSV order.
  @Query(r'''
INSERT INTO product_images (id, product_id, url, rank)
VALUES ($1, $2, $3, $4)
''')
  Future<Result<ExecResult, SqlxError>> insertImage(
    String id,
    String productId,
    String url,
    int rank,
  );

  /// Replaces public tag membership without deleting reusable tags.
  @Query(r'DELETE FROM product_tag_products WHERE product_id = $1')
  Future<Result<ExecResult, SqlxError>> clearTags(String productId);

  /// Finds an active reusable tag case-insensitively.
  @Query(r'''
SELECT id FROM product_tags
WHERE lower(value) = lower($1) AND deleted_at IS NULL
''')
  Future<Result<AdminProductImportIdRow?, SqlxError>> findTag(String value);

  /// Creates one reusable public tag.
  @Query(r'INSERT INTO product_tags (id, value) VALUES ($1, $2)')
  Future<Result<ExecResult, SqlxError>> insertTag(String id, String value);

  /// Attaches one reusable tag to a product.
  @Query(r'''
INSERT INTO product_tag_products (product_id, tag_id) VALUES ($1, $2)
ON CONFLICT DO NOTHING
''')
  Future<Result<ExecResult, SqlxError>> linkTag(
    String productId,
    String tagId,
  );

  /// Finds an active option already attached to this product by title.
  @Query(r'''
SELECT option.id
FROM product_product_options link
JOIN product_options option ON option.id = link.product_option_id
WHERE link.product_id = $1 AND option.title = $2
  AND link.deleted_at IS NULL AND option.deleted_at IS NULL
''')
  Future<Result<AdminProductImportIdRow?, SqlxError>> findOption(
    String productId,
    String title,
  );

  /// Creates one product-exclusive option axis.
  @Query(r'''
INSERT INTO product_options (id, title, is_exclusive) VALUES ($1, $2, 1)
''')
  Future<Result<ExecResult, SqlxError>> insertOption(String id, String title);

  /// Attaches one option axis to the imported product.
  @Query(r'''
INSERT INTO product_product_options
  (id, product_id, product_option_id) VALUES ($1, $2, $3)
''')
  Future<Result<ExecResult, SqlxError>> insertProductOption(
    String id,
    String productId,
    String optionId,
  );

  /// Finds the active product-option pivot.
  @Query(r'''
SELECT id FROM product_product_options
WHERE product_id = $1 AND product_option_id = $2 AND deleted_at IS NULL
''')
  Future<Result<AdminProductImportIdRow?, SqlxError>> findProductOption(
    String productId,
    String optionId,
  );

  /// Finds an active value owned by an option axis.
  @Query(r'''
SELECT id FROM product_option_values
WHERE option_id = $1 AND value = $2 AND deleted_at IS NULL
''')
  Future<Result<AdminProductImportIdRow?, SqlxError>> findOptionValue(
    String optionId,
    String value,
  );

  /// Computes the next stable display rank for a newly imported value.
  @Query(r'''
SELECT coalesce(max(rank), -1) + 1 FROM product_option_values
WHERE option_id = $1 AND deleted_at IS NULL
''')
  Future<Result<int, SqlxError>> nextOptionValueRank(String optionId);

  /// Creates one value on an imported option axis.
  @Query(r'''
INSERT INTO product_option_values (id, option_id, value, rank)
VALUES ($1, $2, $3, $4)
''')
  Future<Result<ExecResult, SqlxError>> insertOptionValue(
    String id,
    String optionId,
    String value,
    int rank,
  );

  /// Makes one option value available to the product.
  @Query(r'''
INSERT INTO product_product_option_values
  (id, product_product_option_id, product_option_value_id)
VALUES ($1, $2, $3)
''')
  Future<Result<ExecResult, SqlxError>> linkProductOptionValue(
    String id,
    String productOptionId,
    String optionValueId,
  );

  /// Selects exactly one value for this variant and option axis.
  @Query(r'''
INSERT INTO variant_option_values (variant_id, option_id, option_value_id)
VALUES ($1, $2, $3)
ON CONFLICT (variant_id, option_id)
DO UPDATE SET option_value_id = excluded.option_value_id
''')
  Future<Result<ExecResult, SqlxError>> upsertVariantOptionValue(
    String variantId,
    String optionId,
    String optionValueId,
  );

  /// Replaces the exact integer-minor-unit price in one currency.
  @Query(r'''
INSERT INTO variant_prices (variant_id, currency_code, amount)
VALUES ($1, $2, $3)
ON CONFLICT (variant_id, currency_code)
DO UPDATE SET amount = excluded.amount
''')
  Future<Result<ExecResult, SqlxError>> upsertPrice(
    String variantId,
    String currencyCode,
    int amount,
  );
}
