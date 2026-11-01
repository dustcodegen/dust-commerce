import 'package:commerce_server/src/features/admin/model.dart';
import 'package:dust_dart/db.dart';

part 'product_create.g.dart';

/// Atomic product-graph writes used only by the protected admin API.
@SqlxDao()
abstract final class AdminProductCreateRepository {
  /// Binds creation queries to [db].
  const factory AdminProductCreateRepository(Executor db) =
      _$AdminProductCreateRepository;

  /// Returns currencies that can make a published product visible in-store.
  @Query(r'''
SELECT DISTINCT currency_code
FROM regions
WHERE deleted_at IS NULL
ORDER BY currency_code
''')
  Future<Result<List<AdminProductCurrencyResponse>, SqlxError>>
      activeCurrencies();

  /// Confirms a requested classification is currently merchant-selectable.
  @Query(r'''
SELECT count(*)
FROM product_types
WHERE id = $1 AND deleted_at IS NULL
''')
  Future<Result<int, SqlxError>> activeProductTypeCount(String id);

  /// Inserts the product only when no active row owns [handle].
  @Query(r'''
INSERT INTO products
  (id, title, handle, subtitle, material, description, thumbnail, type_id,
   discountable, status)
SELECT $1, trim($2), $3, nullif(trim($4), ''), nullif(trim($5), ''),
       nullif(trim($6), ''), $7, $8, $9, $10
WHERE NOT EXISTS (
  SELECT 1 FROM products
  WHERE handle = $3 AND deleted_at IS NULL
)
''')
  Future<Result<ExecResult, SqlxError>> insertProduct(
    String id,
    String title,
    String handle,
    String? subtitle,
    String? material,
    String? description,
    String? thumbnail,
    String? typeId,
    int discountable,
    String status,
  );

  /// Attaches one uploaded image in merchant-defined gallery order.
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

  /// Creates one exclusive option axis for the new product graph.
  @Query(r'''
INSERT INTO product_options (id, title, is_exclusive)
VALUES ($1, $2, 1)
''')
  Future<Result<ExecResult, SqlxError>> insertOption(
    String id,
    String title,
  );

  /// Attaches an option to the product through Medusa's explicit pivot.
  @Query(r'''
INSERT INTO product_product_options (id, product_id, product_option_id)
VALUES ($1, $2, $3)
''')
  Future<Result<ExecResult, SqlxError>> insertProductOption(
    String id,
    String productId,
    String optionId,
  );

  /// Creates one stable, ranked value for an option axis.
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

  /// Makes one option value available on the new product link.
  @Query(r'''
INSERT INTO product_product_option_values
  (id, product_product_option_id, product_option_value_id)
VALUES ($1, $2, $3)
''')
  Future<Result<ExecResult, SqlxError>> insertProductOptionValue(
    String id,
    String productOptionId,
    String optionValueId,
  );

  /// Creates one inventory-bearing variant unless its SKU is already active.
  @Query(r'''
INSERT INTO product_variants
  (id, product_id, title, sku, inventory_quantity,
   manage_inventory, allow_backorder)
SELECT $1, $2, $3, nullif(trim($4), ''), $5, $6, $7
WHERE $4 IS NULL OR trim($4) = '' OR NOT EXISTS (
  SELECT 1 FROM product_variants
  WHERE sku = trim($4) AND deleted_at IS NULL
)
''')
  Future<Result<ExecResult, SqlxError>> insertVariant(
    String id,
    String productId,
    String title,
    String? sku,
    int inventoryQuantity,
    int manageInventory,
    int allowBackorder,
  );

  /// Links one variant to exactly one value for an option axis.
  @Query(r'''
INSERT INTO variant_option_values
  (variant_id, option_id, option_value_id)
VALUES ($1, $2, $3)
''')
  Future<Result<ExecResult, SqlxError>> insertVariantOptionValue(
    String variantId,
    String optionId,
    String optionValueId,
  );

  /// Assigns one exact integer-minor-unit regional price.
  @Query(r'''
INSERT INTO variant_prices (variant_id, currency_code, amount)
VALUES ($1, $2, $3)
''')
  Future<Result<ExecResult, SqlxError>> insertPrice(
    String variantId,
    String currencyCode,
    int amount,
  );

  /// Removes an uncommitted graph after a classified create conflict.
  @Query(r'DELETE FROM products WHERE id = $1')
  Future<Result<ExecResult, SqlxError>> deleteCreatedProduct(String id);
}
