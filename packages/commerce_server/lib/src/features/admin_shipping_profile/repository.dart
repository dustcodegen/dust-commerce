import 'package:commerce_server/src/features/admin_shipping_profile/model.dart';
import 'package:dust_dart/db.dart';

part 'repository.g.dart';

/// Direct SQLx persistence for protected product fulfillment configuration.
@SqlxDao()
abstract final class AdminShippingProfileRepository {
  /// Binds shipping-profile operations to [db].
  const factory AdminShippingProfileRepository(Executor db) =
      _$AdminShippingProfileRepository;

  /// Lists active profiles after applying the Admin query boundary.
  @Query(r'''
SELECT id, name, type, created_at, updated_at
FROM shipping_profile
WHERE deleted_at IS NULL
  AND ($1 = '' OR lower(name) LIKE '%' || lower($1) || '%'
       OR lower(type) LIKE '%' || lower($1) || '%')
  AND ($2 = '' OR lower(name) LIKE '%' || lower($2) || '%')
  AND ($3 = '' OR lower(type) LIKE '%' || lower($3) || '%')
  AND (NULLIF($4, '') IS NULL OR created_at > NULLIF($4, '')::timestamptz)
  AND (NULLIF($5, '') IS NULL OR created_at >= NULLIF($5, '')::timestamptz)
  AND (NULLIF($6, '') IS NULL OR created_at < NULLIF($6, '')::timestamptz)
  AND (NULLIF($7, '') IS NULL OR created_at <= NULLIF($7, '')::timestamptz)
  AND (NULLIF($8, '') IS NULL OR updated_at > NULLIF($8, '')::timestamptz)
  AND (NULLIF($9, '') IS NULL OR updated_at >= NULLIF($9, '')::timestamptz)
  AND (NULLIF($10, '') IS NULL OR updated_at < NULLIF($10, '')::timestamptz)
  AND (NULLIF($11, '') IS NULL OR updated_at <= NULLIF($11, '')::timestamptz)
ORDER BY
  CASE WHEN $12 = 'name' THEN lower(name) END ASC,
  CASE WHEN $12 = '-name' THEN lower(name) END DESC,
  CASE WHEN $12 = 'type' THEN lower(type) END ASC,
  CASE WHEN $12 = '-type' THEN lower(type) END DESC,
  CASE WHEN $12 = 'created_at' THEN created_at END ASC,
  CASE WHEN $12 = '-created_at' THEN created_at END DESC,
  CASE WHEN $12 = 'updated_at' THEN updated_at END ASC,
  CASE WHEN $12 = '-updated_at' THEN updated_at END DESC,
  lower(name), id
LIMIT $13 OFFSET $14
''')
  Future<Result<List<AdminShippingProfileResponse>, SqlxError>> list(
    String query,
    String name,
    String type,
    String createdAfter,
    String createdFrom,
    String createdBefore,
    String createdThrough,
    String updatedAfter,
    String updatedFrom,
    String updatedBefore,
    String updatedThrough,
    String order,
    int limit,
    int offset,
  );

  /// Counts the same filtered profile result before paging.
  @Query(r'''
SELECT count(*)
FROM shipping_profile
WHERE deleted_at IS NULL
  AND ($1 = '' OR lower(name) LIKE '%' || lower($1) || '%'
       OR lower(type) LIKE '%' || lower($1) || '%')
  AND ($2 = '' OR lower(name) LIKE '%' || lower($2) || '%')
  AND ($3 = '' OR lower(type) LIKE '%' || lower($3) || '%')
  AND (NULLIF($4, '') IS NULL OR created_at > NULLIF($4, '')::timestamptz)
  AND (NULLIF($5, '') IS NULL OR created_at >= NULLIF($5, '')::timestamptz)
  AND (NULLIF($6, '') IS NULL OR created_at < NULLIF($6, '')::timestamptz)
  AND (NULLIF($7, '') IS NULL OR created_at <= NULLIF($7, '')::timestamptz)
  AND (NULLIF($8, '') IS NULL OR updated_at > NULLIF($8, '')::timestamptz)
  AND (NULLIF($9, '') IS NULL OR updated_at >= NULLIF($9, '')::timestamptz)
  AND (NULLIF($10, '') IS NULL OR updated_at < NULLIF($10, '')::timestamptz)
  AND (NULLIF($11, '') IS NULL OR updated_at <= NULLIF($11, '')::timestamptz)
''')
  Future<Result<int, SqlxError>> count(
    String query,
    String name,
    String type,
    String createdAfter,
    String createdFrom,
    String createdBefore,
    String createdThrough,
    String updatedAfter,
    String updatedFrom,
    String updatedBefore,
    String updatedThrough,
  );

  /// Confirms the routed product exists without leaking soft-deleted rows.
  @Query(r'''
SELECT count(*) FROM products WHERE id = $1 AND deleted_at IS NULL
''')
  Future<Result<int, SqlxError>> activeProductCount(String productId);

  /// Confirms a requested fulfillment profile remains selectable.
  @Query(r'''
SELECT count(*) FROM shipping_profile WHERE id = $1 AND deleted_at IS NULL
''')
  Future<Result<int, SqlxError>> activeProfileCount(String shippingProfileId);

  /// Reads the scalar active profile for one active product.
  @Query(r'''
SELECT profile.id, profile.name, profile.type,
       profile.created_at, profile.updated_at
FROM product_shipping_profile link
JOIN shipping_profile profile ON profile.id = link.shipping_profile_id
JOIN products product ON product.id = link.product_id
WHERE link.product_id = $1 AND link.deleted_at IS NULL
  AND profile.deleted_at IS NULL AND product.deleted_at IS NULL
LIMIT 1
''')
  Future<Result<AdminShippingProfileResponse?, SqlxError>> currentForProduct(
    String productId,
  );

  /// Soft-deletes the current assignment before replacement or clearing.
  @Query(r'''
UPDATE product_shipping_profile
SET deleted_at = strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
WHERE product_id = $1 AND deleted_at IS NULL
''')
  Future<Result<ExecResult, SqlxError>> removeCurrent(String productId);

  /// Restores the newest historical match instead of duplicating it.
  @Query(r'''
UPDATE product_shipping_profile
SET deleted_at = NULL
WHERE id = (
  SELECT id FROM product_shipping_profile
  WHERE product_id = $1 AND shipping_profile_id = $2
    AND deleted_at IS NOT NULL
  ORDER BY created_at DESC, id DESC
  LIMIT 1
)
AND NOT EXISTS (
  SELECT 1 FROM product_shipping_profile active
  WHERE active.product_id = $1 AND active.deleted_at IS NULL
)
''')
  Future<Result<ExecResult, SqlxError>> restore(
    String productId,
    String shippingProfileId,
  );

  /// Creates the first durable link for a product/profile pair.
  @Query(r'''
INSERT INTO product_shipping_profile (id, product_id, shipping_profile_id)
VALUES ($1, $2, $3)
''')
  Future<Result<ExecResult, SqlxError>> insert(
    String id,
    String productId,
    String shippingProfileId,
  );
}
