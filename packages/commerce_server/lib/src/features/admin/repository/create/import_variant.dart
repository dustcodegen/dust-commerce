import 'package:dust_dart/db.dart';

part 'import_variant.g.dart';

/// Variant-core writes used only inside an import transaction.
@SqlxDao()
abstract final class AdminProductImportVariantRepository {
  /// Binds imported variant writes to [db].
  const factory AdminProductImportVariantRepository(Executor db) =
      _$AdminProductImportVariantRepository;

  /// Creates one fully described variant with zero initial inventory.
  @Query(r'''
INSERT INTO product_variants
  (id, product_id, title, material, sku, barcode, inventory_quantity,
   manage_inventory, allow_backorder, weight, width, length, height,
   mid_code, hs_code, origin_country)
VALUES
  ($1, $2, $3, $4, $5, $6, 0, $7, $8, $9, $10, $11, $12, $13, $14, $15)
''')
  Future<Result<ExecResult, SqlxError>> insertVariant(
    String id,
    String productId,
    String title,
    String? material,
    String? sku,
    String? barcode,
    int manageInventory,
    int allowBackorder,
    int? weight,
    int? width,
    int? length,
    int? height,
    String? midCode,
    String? hsCode,
    String? originCountry,
  );

  /// Updates staged fields while retaining omitted values and stock quantity.
  @Query(r'''
UPDATE product_variants SET
  title = json_extract($3, '$.title'),
  material = CASE WHEN json_type($3, '$.material') IS NULL
    THEN material ELSE json_extract($3, '$.material') END,
  sku = CASE WHEN json_type($3, '$.sku') IS NULL
    THEN sku ELSE json_extract($3, '$.sku') END,
  barcode = CASE WHEN json_type($3, '$.barcode') IS NULL
    THEN barcode ELSE json_extract($3, '$.barcode') END,
  manage_inventory = CASE WHEN json_type($3, '$.manage_inventory') IS NULL
    THEN manage_inventory ELSE json_extract($3, '$.manage_inventory')::integer END,
  allow_backorder = CASE WHEN json_type($3, '$.allow_backorder') IS NULL
    THEN allow_backorder ELSE json_extract($3, '$.allow_backorder')::integer END,
  weight = CASE WHEN json_type($3, '$.weight') IS NULL
    THEN weight ELSE json_extract($3, '$.weight')::double precision END,
  width = CASE WHEN json_type($3, '$.width') IS NULL
    THEN width ELSE json_extract($3, '$.width')::double precision END,
  length = CASE WHEN json_type($3, '$.length') IS NULL
    THEN length ELSE json_extract($3, '$.length')::double precision END,
  height = CASE WHEN json_type($3, '$.height') IS NULL
    THEN height ELSE json_extract($3, '$.height')::double precision END,
  mid_code = CASE WHEN json_type($3, '$.mid_code') IS NULL
    THEN mid_code ELSE json_extract($3, '$.mid_code') END,
  hs_code = CASE WHEN json_type($3, '$.hs_code') IS NULL
    THEN hs_code ELSE json_extract($3, '$.hs_code') END,
  origin_country = CASE WHEN json_type($3, '$.origin_country') IS NULL
    THEN origin_country ELSE json_extract($3, '$.origin_country') END
WHERE id = $1 AND product_id = $2 AND deleted_at IS NULL
''')
  Future<Result<ExecResult, SqlxError>> updateVariant(
    String id,
    String productId,
    String fieldsJson,
  );
}
