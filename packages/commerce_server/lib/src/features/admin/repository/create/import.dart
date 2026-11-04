import 'package:dust_dart/db.dart';

part 'import.g.dart';

/// Staging queries for product-import previews.
@SqlxDao()
abstract final class AdminProductImportRepository {
  /// Binds import staging to [db].
  const factory AdminProductImportRepository(Executor db) =
      _$AdminProductImportRepository;

  /// Counts unique incoming identities already present in the active catalogue.
  @Query(r'''
SELECT count(*)
FROM jsonb_array_elements($1::jsonb) incoming(value)
WHERE EXISTS (
  SELECT 1
  FROM products product
  WHERE product.deleted_at IS NULL
    AND (
      (json_extract(incoming.value, '$.id') <> ''
       AND product.id = json_extract(incoming.value, '$.id'))
      OR product.handle = json_extract(incoming.value, '$.handle')
    )
)
''')
  Future<Result<int, SqlxError>> countExisting(String identitiesJson);

  /// Finds identities that point at two different active products.
  @Query(r'''
SELECT count(*)
FROM jsonb_array_elements($1::jsonb) incoming(value)
WHERE (
  SELECT count(DISTINCT product.id)
  FROM products product
  WHERE product.deleted_at IS NULL
    AND (
      (json_extract(incoming.value, '$.id') <> ''
       AND product.id = json_extract(incoming.value, '$.id'))
      OR product.handle = json_extract(incoming.value, '$.handle')
    )
) > 1
''')
  Future<Result<int, SqlxError>> countAmbiguous(String identitiesJson);

  /// Persists normalized rows without changing any catalogue table.
  @Query(r'''
INSERT INTO product_imports
  (id, admin_user_id, filename, payload_json, to_create, to_update, expires_at)
VALUES ($1, $2, $3, $4, $5, $6, $7)
''')
  Future<Result<ExecResult, SqlxError>> insert(
    String id,
    String adminUserId,
    String filename,
    String payloadJson,
    int toCreate,
    int toUpdate,
    String expiresAt,
  );
}
