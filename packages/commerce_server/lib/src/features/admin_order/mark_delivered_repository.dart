import 'package:commerce_server/src/features/admin_order/mark_delivered_model.dart';
import 'package:dust_dart/db.dart';

part 'mark_delivered_repository.g.dart';

/// Transaction-scoped persistence for fulfillment delivery.
@SqlxDao()
abstract final class AdminMarkDeliveredRepository {
  /// Binds lifecycle validation and writes to [db].
  const factory AdminMarkDeliveredRepository(Executor db) =
      _$AdminMarkDeliveredRepository;

  /// Reads route ownership and final lifecycle state without exposing a record.
  @Query(r'''
SELECT fulfillment.canceled_at IS NOT NULL AS canceled,
       fulfillment.delivered_at IS NOT NULL AS delivered
FROM fulfillments fulfillment
JOIN orders order_row ON order_row.id = fulfillment.order_id
WHERE order_row.id = $1 AND fulfillment.id = $2
  AND order_row.deleted_at IS NULL AND fulfillment.deleted_at IS NULL
''')
  Future<Result<AdminDeliveryTarget?, SqlxError>> target(
    String orderId,
    String fulfillmentId,
  );

  /// Marks one active fulfillment delivered using PostgreSQL's UTC clock.
  @Query(r'''
UPDATE fulfillments
SET delivered_at = strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
WHERE order_id = $1 AND id = $2 AND deleted_at IS NULL
  AND canceled_at IS NULL AND delivered_at IS NULL
''')
  Future<Result<ExecResult, SqlxError>> markDelivered(
    String orderId,
    String fulfillmentId,
  );
}
