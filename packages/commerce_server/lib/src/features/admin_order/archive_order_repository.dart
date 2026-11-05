import 'package:commerce_server/src/features/admin_order/archive_order_model.dart';
import 'package:dust_dart/db.dart';

part 'archive_order_repository.g.dart';

/// Transaction-scoped persistence for Medusa-compatible order archival.
@SqlxDao()
abstract final class AdminArchiveOrderRepository {
  /// Binds lifecycle reads and writes to [db].
  const factory AdminArchiveOrderRepository(Executor db) =
      _$AdminArchiveOrderRepository;

  /// Reads only the lifecycle fact required by Medusa's archival rule.
  @Query(r'''
SELECT status FROM orders WHERE id = $1 AND deleted_at IS NULL
''')
  Future<Result<AdminArchiveOrderTarget?, SqlxError>> target(String orderId);

  /// Archives an eligible order; PostgreSQL owns `updated_at`.
  @Query(r'''
UPDATE orders SET status = 'archived'
WHERE id = $1 AND status IN ('completed', 'canceled')
  AND deleted_at IS NULL
''')
  Future<Result<ExecResult, SqlxError>> archive(String orderId);
}
