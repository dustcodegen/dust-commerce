import 'package:commerce_server/src/features/admin_promotion/model.dart';
import 'package:dust_dart/db.dart';

part 'create.g.dart';

/// Direct SQLx persistence for merchant-created promotions.
@SqlxDao()
abstract final class AdminPromotionCreateRepository {
  /// Binds promotion creation to [db].
  const factory AdminPromotionCreateRepository(Executor db) =
      _$AdminPromotionCreateRepository;

  /// Inserts one promotion and returns its explicit Admin projection.
  @Query(r'''
INSERT INTO promotions
  (id, code, type, value, currency_code, starts_at, ends_at, usage_limit)
VALUES ($1, $2, $3, $4, $5, NULLIF($6, '')::timestamptz,
        NULLIF($7, '')::timestamptz, $8)
ON CONFLICT DO NOTHING
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
  Future<Result<AdminPromotionResponse?, SqlxError>> insert(
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
