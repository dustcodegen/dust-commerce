import 'package:commerce_server/src/features/admin_promotion/model.dart';
import 'package:dust_dart/db.dart';

part 'repository.g.dart';

/// Read-only promotion queries used by the protected Admin list.
@SqlxDao()
abstract final class AdminPromotionRepository {
  /// Binds promotion queries to [db].
  const factory AdminPromotionRepository(Executor db) =
      _$AdminPromotionRepository;

  /// Lists active promotions with Medusa's table columns.
  @Query(r'''
SELECT id, code, type, value, currency_code, starts_at, ends_at, usage_limit,
       usage_count, created_at, updated_at, FALSE AS is_automatic,
       CASE
         WHEN starts_at IS NOT NULL
              AND starts_at > strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
           THEN 'scheduled'
         WHEN (ends_at IS NOT NULL
               AND ends_at < strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
              OR (usage_limit IS NOT NULL AND usage_count >= usage_limit)
           THEN 'expired'
         ELSE 'active'
       END AS status
FROM promotions
WHERE deleted_at IS NULL
  AND ($1 = '' OR lower(code) LIKE '%' || lower($1) || '%')
  AND (NULLIF($2, '') IS NULL OR created_at > NULLIF($2, '')::timestamptz)
  AND (NULLIF($3, '') IS NULL OR created_at >= NULLIF($3, '')::timestamptz)
  AND (NULLIF($4, '') IS NULL OR created_at < NULLIF($4, '')::timestamptz)
  AND (NULLIF($5, '') IS NULL OR created_at <= NULLIF($5, '')::timestamptz)
  AND (NULLIF($6, '') IS NULL OR updated_at > NULLIF($6, '')::timestamptz)
  AND (NULLIF($7, '') IS NULL OR updated_at >= NULLIF($7, '')::timestamptz)
  AND (NULLIF($8, '') IS NULL OR updated_at < NULLIF($8, '')::timestamptz)
  AND (NULLIF($9, '') IS NULL OR updated_at <= NULLIF($9, '')::timestamptz)
ORDER BY
  CASE WHEN $10 = 'created_at' THEN created_at END ASC,
  CASE WHEN $10 = '-created_at' THEN created_at END DESC,
  CASE WHEN $10 = 'updated_at' THEN updated_at END ASC,
  CASE WHEN $10 = '-updated_at' THEN updated_at END DESC,
  id ASC
LIMIT $11 OFFSET $12
''')
  Future<Result<List<AdminPromotionResponse>, SqlxError>> list(
    String query,
    String createdAfter,
    String createdFrom,
    String createdBefore,
    String createdTo,
    String updatedAfter,
    String updatedFrom,
    String updatedBefore,
    String updatedTo,
    String order,
    int limit,
    int offset,
  );

  /// Counts active promotions matching the same filter set.
  @Query(r'''
SELECT count(*)
FROM promotions
WHERE deleted_at IS NULL
  AND ($1 = '' OR lower(code) LIKE '%' || lower($1) || '%')
  AND (NULLIF($2, '') IS NULL OR created_at > NULLIF($2, '')::timestamptz)
  AND (NULLIF($3, '') IS NULL OR created_at >= NULLIF($3, '')::timestamptz)
  AND (NULLIF($4, '') IS NULL OR created_at < NULLIF($4, '')::timestamptz)
  AND (NULLIF($5, '') IS NULL OR created_at <= NULLIF($5, '')::timestamptz)
  AND (NULLIF($6, '') IS NULL OR updated_at > NULLIF($6, '')::timestamptz)
  AND (NULLIF($7, '') IS NULL OR updated_at >= NULLIF($7, '')::timestamptz)
  AND (NULLIF($8, '') IS NULL OR updated_at < NULLIF($8, '')::timestamptz)
  AND (NULLIF($9, '') IS NULL OR updated_at <= NULLIF($9, '')::timestamptz)
''')
  Future<Result<int, SqlxError>> count(
    String query,
    String createdAfter,
    String createdFrom,
    String createdBefore,
    String createdTo,
    String updatedAfter,
    String updatedFrom,
    String updatedBefore,
    String updatedTo,
  );

  /// Reads one active promotion row.
  @Query(r'''
SELECT id, code, type, value, currency_code, starts_at, ends_at, usage_limit,
       usage_count, created_at, updated_at, FALSE AS is_automatic,
       CASE
         WHEN starts_at IS NOT NULL
              AND starts_at > strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
           THEN 'scheduled'
         WHEN (ends_at IS NOT NULL
               AND ends_at < strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
              OR (usage_limit IS NOT NULL AND usage_count >= usage_limit)
           THEN 'expired'
         ELSE 'active'
       END AS status
FROM promotions
WHERE id = $1 AND deleted_at IS NULL
''')
  Future<Result<AdminPromotionResponse?, SqlxError>> find(String id);

  /// Checks whether another active promotion owns [code].
  @Query(r'''
SELECT EXISTS (
  SELECT 1 FROM promotions
  WHERE code = $1 AND id <> $2 AND deleted_at IS NULL
)
''')
  Future<Result<bool, SqlxError>> codeExists(String code, String excludingId);
}
