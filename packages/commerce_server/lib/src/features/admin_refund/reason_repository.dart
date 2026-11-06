import 'package:commerce_server/src/features/admin_refund/reason_model.dart';
import 'package:dust_dart/db.dart';

part 'reason_repository.g.dart';

/// Protected reads for merchant-managed refund reasons.
@SqlxDao()
abstract final class AdminRefundReasonRepository {
  /// Binds reason discovery to [db].
  const factory AdminRefundReasonRepository(Executor db) =
      _$AdminRefundReasonRepository;

  /// Counts active reasons matching the merchant query.
  @Query(r'''
SELECT count(*) FROM refund_reasons
WHERE deleted_at IS NULL AND (
  $1 = '' OR lower(label) LIKE '%' || lower($1) || '%'
          OR lower(coalesce(description, '')) LIKE '%' || lower($1) || '%'
)
''')
  Future<Result<int, SqlxError>> count(String query);

  /// Lists active reason choices in stable label order.
  @Query(r'''
SELECT id, label, code, description
FROM refund_reasons
WHERE deleted_at IS NULL AND (
  $1 = '' OR lower(label) LIKE '%' || lower($1) || '%'
          OR lower(coalesce(description, '')) LIKE '%' || lower($1) || '%'
)
ORDER BY lower(label), id
LIMIT $2 OFFSET $3
''')
  Future<Result<List<AdminRefundReasonResponse>, SqlxError>> list(
    String query,
    int limit,
    int offset,
  );

  /// Inserts one active reason and returns its public projection.
  @Query(r'''
INSERT INTO refund_reasons (id, label, code, description)
VALUES ($1, $2, $3, $4)
ON CONFLICT DO NOTHING
RETURNING id, label, code, description
''')
  Future<Result<AdminRefundReasonResponse?, SqlxError>> insert(
    String id,
    String label,
    String code,
    String? description,
  );

  /// Replaces editable fields while preserving refund history.
  @Query(r'''
UPDATE refund_reasons
SET label = $2, code = $3, description = $4
WHERE id = $1 AND deleted_at IS NULL
  AND NOT EXISTS (
    SELECT 1 FROM refund_reasons conflict
    WHERE conflict.id <> $1
      AND conflict.deleted_at IS NULL
      AND conflict.code = $3
  )
RETURNING id, label, code, description
''')
  Future<Result<AdminRefundReasonResponse?, SqlxError>> update(
    String id,
    String label,
    String code,
    String? description,
  );

  /// Retires one active reason without rewriting historical refunds.
  @Query(r'''
UPDATE refund_reasons
SET deleted_at = CURRENT_TIMESTAMP
WHERE id = $1 AND deleted_at IS NULL
RETURNING id
''')
  Future<Result<String?, SqlxError>> retire(String id);
}
