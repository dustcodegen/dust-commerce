import 'package:commerce_server/src/features/admin_order/complete_order_model.dart';
import 'package:dust_dart/db.dart';

part 'complete_order_repository.g.dart';

/// Transaction-scoped persistence for Medusa-compatible order completion.
@SqlxDao()
abstract final class AdminCompleteOrderRepository {
  /// Binds lifecycle reads and writes to [db].
  const factory AdminCompleteOrderRepository(Executor db) =
      _$AdminCompleteOrderRepository;

  /// Reads only the lifecycle fact required by Medusa's completion rule.
  @Query(r'''
SELECT status FROM orders WHERE id = $1 AND deleted_at IS NULL
''')
  Future<Result<AdminCompleteOrderTarget?, SqlxError>> target(String orderId);

  /// Marks any non-canceled order completed; PostgreSQL owns `updated_at`.
  @Query(r'''
UPDATE orders SET status = 'completed'
WHERE id = $1 AND status <> 'canceled' AND deleted_at IS NULL
''')
  Future<Result<ExecResult, SqlxError>> complete(String orderId);
}
