import 'package:commerce_server/src/features/admin_order/create_shipment_model.dart';
import 'package:dust_dart/db.dart';

part 'create_shipment_repository.g.dart';

/// Transaction-scoped persistence for Admin shipment creation.
@SqlxDao()
abstract final class AdminCreateShipmentRepository {
  /// Binds shipment validation and writes to [db].
  const factory AdminCreateShipmentRepository(Executor db) =
      _$AdminCreateShipmentRepository;

  /// Reads route ownership and lifecycle without exposing a foreign record.
  @Query(r'''
SELECT fulfillment.requires_shipping = 1 AS requires_shipping,
       fulfillment.canceled_at IS NOT NULL AS canceled,
       fulfillment.shipped_at IS NOT NULL AS shipped,
       fulfillment.delivered_at IS NOT NULL AS delivered
FROM fulfillments fulfillment
JOIN orders order_row ON order_row.id = fulfillment.order_id
WHERE order_row.id = $1 AND fulfillment.id = $2
  AND order_row.deleted_at IS NULL AND fulfillment.deleted_at IS NULL
''')
  Future<Result<AdminShipmentTarget?, SqlxError>> target(
    String orderId,
    String fulfillmentId,
  );

  /// Reads every active frozen item for exact shipment matching.
  @Query(r'''
SELECT line_item_id AS id, quantity
FROM fulfillment_items
WHERE fulfillment_id = $1 AND deleted_at IS NULL
ORDER BY created_at, id
''')
  Future<Result<List<AdminShipmentStoredItem>, SqlxError>> items(
    String fulfillmentId,
  );

  /// Reads active labels so Medusa's resubmitted provider labels stay unique.
  @Query(r'''
SELECT tracking_number, tracking_url, label_url
FROM fulfillment_labels
WHERE fulfillment_id = $1 AND deleted_at IS NULL
ORDER BY created_at, id
''')
  Future<Result<List<AdminShipmentStoredLabel>, SqlxError>> labels(
    String fulfillmentId,
  );

  /// Marks one still-pending physical fulfillment shipped using PostgreSQL time.
  @Query(r'''
UPDATE fulfillments
SET shipped_at = strftime('%Y-%m-%dT%H:%M:%fZ', 'now'),
    marked_shipped_by = $3
WHERE order_id = $1 AND id = $2 AND deleted_at IS NULL
  AND requires_shipping = 1 AND canceled_at IS NULL
  AND shipped_at IS NULL AND delivered_at IS NULL
''')
  Future<Result<ExecResult, SqlxError>> markShipped(
    String orderId,
    String fulfillmentId,
    String adminId,
  );

  /// Persists one validated carrier label without application timestamps.
  @Query(r'''
INSERT INTO fulfillment_labels (
  id, fulfillment_id, tracking_number, tracking_url, label_url
) VALUES ($1, $2, $3, $4, $5)
''')
  Future<Result<ExecResult, SqlxError>> insertLabel(
    String id,
    String fulfillmentId,
    String trackingNumber,
    String trackingUrl,
    String labelUrl,
  );
}
