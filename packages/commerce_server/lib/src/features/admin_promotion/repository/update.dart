import 'package:commerce_server/src/features/admin_promotion/model.dart';
import 'package:dust_dart/db.dart';

part 'update.g.dart';

/// Direct SQLx persistence for merchant promotion replacements.
@SqlxDao()
abstract final class AdminPromotionUpdateRepository {
  /// Binds promotion updates to [db].
  const factory AdminPromotionUpdateRepository(Executor db) =
      _$AdminPromotionUpdateRepository;

  /// Replaces editable fields and returns the refreshed allowlisted row.
  @Query(r'''
UPDATE promotions
SET code = $2,
    type = $3,
    value = $4,
    currency_code = $5,
    starts_at = NULLIF($6, '')::timestamptz,
    ends_at = NULLIF($7, '')::timestamptz,
    usage_limit = $8
WHERE id = $1 AND deleted_at IS NULL
  AND (CAST($8 AS INTEGER) IS NULL OR usage_count <= CAST($8 AS INTEGER))
  AND NOT EXISTS (
    SELECT 1 FROM promotions conflict
    WHERE conflict.id <> $1
      AND conflict.deleted_at IS NULL
      AND conflict.code = $2
  )
RETURNING id, code, type, value, currency_code, starts_at, ends_at,
          usage_limit, usage_count, created_at, updated_at,
          FALSE AS is_automatic,
          CASE
            WHEN starts_at IS NOT NULL AND starts_at > CURRENT_TIMESTAMP
              THEN 'scheduled'
            WHEN (ends_at IS NOT NULL AND ends_at < CURRENT_TIMESTAMP)
                 OR (usage_limit IS NOT NULL AND usage_count >= usage_limit)
              THEN 'expired'
            ELSE 'active'
          END AS status
''')
  Future<Result<AdminPromotionResponse?, SqlxError>> update(
    String id,
    String code,
    String type,
    int value,
    String? currencyCode,
    String startsAt,
    String endsAt,
    int? usageLimit,
  );
}
