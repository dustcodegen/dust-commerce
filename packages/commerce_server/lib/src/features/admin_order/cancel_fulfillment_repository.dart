import 'package:commerce_server/src/features/admin_order/cancel_fulfillment_model.dart';
import 'package:dust_dart/db.dart';

part 'cancel_fulfillment_repository.g.dart';

/// Transaction-scoped persistence for fulfillment cancellation.
@SqlxDao()
abstract final class AdminCancelFulfillmentRepository {
  /// Binds lifecycle validation and writes to [db].
  const factory AdminCancelFulfillmentRepository(Executor db) =
      _$AdminCancelFulfillmentRepository;

  /// Reads route ownership, provider, and terminal lifecycle facts.
  @Query(r'''
SELECT fulfillment.provider_id,
       fulfillment.canceled_at IS NOT NULL AS canceled,
       fulfillment.shipped_at IS NOT NULL AS shipped,
       fulfillment.delivered_at IS NOT NULL AS delivered
FROM fulfillments fulfillment
JOIN orders order_row ON order_row.id = fulfillment.order_id
WHERE order_row.id = $1 AND fulfillment.id = $2
  AND order_row.deleted_at IS NULL AND fulfillment.deleted_at IS NULL
''')
  Future<Result<AdminCancelFulfillmentTarget?, SqlxError>> target(
    String orderId,
    String fulfillmentId,
  );

  /// Cancels one pending fulfillment using SQLite's UTC clock.
  @Query(r'''
UPDATE fulfillments
SET canceled_at = strftime('%Y-%m-%dT%H:%M:%fZ', 'now'), canceled_by = $3
WHERE order_id = $1 AND id = $2 AND deleted_at IS NULL
  AND canceled_at IS NULL AND shipped_at IS NULL AND delivered_at IS NULL
''')
  Future<Result<ExecResult, SqlxError>> cancel(
    String orderId,
    String fulfillmentId,
    String adminId,
  );
}
