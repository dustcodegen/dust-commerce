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
}
