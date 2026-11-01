import 'package:dust_dart/db.dart';

part 'import_product.g.dart';

/// Product-shell writes used only inside an import transaction.
@SqlxDao()
abstract final class AdminProductImportProductRepository {
  /// Binds imported product writes to [db].
  const factory AdminProductImportProductRepository(Executor db) =
      _$AdminProductImportProductRepository;

  /// Creates one full product shell after confirmation preflight succeeds.
  @Query(r'''
INSERT INTO products
  (id, collection_id, title, subtitle, handle, description, discountable,
   thumbnail, material, origin_country, type_id, weight, length, width, height,
   status)
VALUES
  ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16)
''')
  Future<Result<ExecResult, SqlxError>> insertProduct(
    String id,
    String? collectionId,
    String title,
    String? subtitle,
    String handle,
    String? description,
    int discountable,
    String? thumbnail,
    String? material,
    String? originCountry,
    String? typeId,
    int? weight,
    int? length,
    int? width,
    int? height,
    String status,
  );

  /// Updates only supported fields present in the staged CSV document.
  @Query(r'''
UPDATE products SET
  title = json_extract($2, '$.title'), handle = json_extract($2, '$.handle'),
  collection_id = CASE WHEN json_type($2, '$.collection_id') IS NULL
    THEN collection_id ELSE json_extract($2, '$.collection_id') END,
  subtitle = CASE WHEN json_type($2, '$.subtitle') IS NULL
    THEN subtitle ELSE json_extract($2, '$.subtitle') END,
  description = CASE WHEN json_type($2, '$.description') IS NULL
    THEN description ELSE json_extract($2, '$.description') END,
  discountable = CASE WHEN json_type($2, '$.discountable') IS NULL
    THEN discountable ELSE json_extract($2, '$.discountable')::integer END,
  thumbnail = CASE WHEN json_type($2, '$.thumbnail') IS NULL
    THEN thumbnail ELSE json_extract($2, '$.thumbnail') END,
  material = CASE WHEN json_type($2, '$.material') IS NULL
    THEN material ELSE json_extract($2, '$.material') END,
  origin_country = CASE WHEN json_type($2, '$.origin_country') IS NULL
    THEN origin_country ELSE json_extract($2, '$.origin_country') END,
  type_id = CASE WHEN json_type($2, '$.type_id') IS NULL
    THEN type_id ELSE json_extract($2, '$.type_id') END,
  weight = CASE WHEN json_type($2, '$.weight') IS NULL
    THEN weight ELSE json_extract($2, '$.weight')::double precision END,
  length = CASE WHEN json_type($2, '$.length') IS NULL
    THEN length ELSE json_extract($2, '$.length')::double precision END,
  width = CASE WHEN json_type($2, '$.width') IS NULL
    THEN width ELSE json_extract($2, '$.width')::double precision END,
  height = CASE WHEN json_type($2, '$.height') IS NULL
    THEN height ELSE json_extract($2, '$.height')::double precision END,
  status = CASE WHEN json_type($2, '$.status') IS NULL
    THEN status ELSE json_extract($2, '$.status') END
WHERE id = $1 AND deleted_at IS NULL
''')
  Future<Result<ExecResult, SqlxError>> updateProduct(
    String id,
    String fieldsJson,
  );
}
