import 'package:commerce_server/src/features/admin_return/model.dart';
import 'package:dust_dart/db.dart';

part 'repository.g.dart';

/// Protected merchant return-list persistence.
@SqlxDao()
abstract final class AdminReturnRepository {
  /// Binds return reads to [db].
  const factory AdminReturnRepository(Executor db) = _$AdminReturnRepository;

  /// Lists the exact fields consumed by Medusa's order-detail return action.
  @Query(r'''
SELECT request.id,
       request.order_id,
       request.display_id,
       request.status,
       request.no_notification = 1 AS no_notification,
       request.refund_amount,
       request.requested_at,
       request.received_at,
       request.canceled_at,
       request.created_at,
       request.updated_at,
       coalesce((
         SELECT json_agg(json_build_object(
           'id', item.id,
           'order_item_id', item.order_item_id,
           'quantity', item.quantity,
           'received_quantity', item.received_quantity,
           'damaged_quantity', item.damaged_quantity,
           'reason_id', item.reason_id,
           'note', item.note
         ))
         FROM (
           SELECT * FROM return_items
           WHERE return_id = request.id
           ORDER BY created_at, id
         ) item
       ), '[]'::json)::text AS items_json
FROM return_requests request
WHERE request.deleted_at IS NULL
  AND request.status IN ('requested', 'received', 'partially_received', 'canceled')
  AND ($1 = '' OR request.id = $1)
  AND ($2 = '' OR request.order_id = $2)
  AND ($3 = '' OR instr(',' || $3 || ',', ',' || request.status || ',') > 0)
ORDER BY request.requested_at DESC, request.id DESC
LIMIT $4 OFFSET $5
''')
  Future<Result<List<AdminReturnResponse>, SqlxError>> list(
    String returnId,
    String orderId,
    String statuses,
    int limit,
    int offset,
  );

  /// Counts active rows using the same filter boundary.
  @Query(r'''
SELECT count(*)
FROM return_requests request
WHERE request.deleted_at IS NULL
  AND request.status IN ('requested', 'received', 'partially_received', 'canceled')
  AND ($1 = '' OR request.order_id = $1)
  AND ($2 = '' OR instr(',' || $2 || ',', ',' || request.status || ',') > 0)
''')
  Future<Result<int, SqlxError>> count(String orderId, String statuses);

  /// Confirms the return is active and still accepts received quantities.
  @Query(r'''
SELECT count(*)
FROM return_requests
WHERE id = $1 AND deleted_at IS NULL
  AND status IN ('requested', 'partially_received')
''')
  Future<Result<int, SqlxError>> receivable(String returnId);

  /// Reads units that remain receivable for one item owned by the return.
  @Query(r'''
SELECT quantity - received_quantity
FROM return_items
WHERE return_id = $1 AND id = $2
''')
  Future<Result<int?, SqlxError>> remaining(String returnId, String itemId);

  /// Adds newly received intact and damaged units when they remain available.
  @Query(r'''
UPDATE return_items
SET received_quantity = received_quantity + $3 + $4,
    damaged_quantity = damaged_quantity + $4
WHERE return_id = $1 AND id = $2
  AND $3 >= 0 AND $4 >= 0 AND $3 + $4 > 0
  AND received_quantity + $3 + $4 <= quantity
  AND EXISTS (
    SELECT 1 FROM return_requests request
    WHERE request.id = $1 AND request.deleted_at IS NULL
      AND request.status IN ('requested', 'partially_received')
  )
''')
  Future<Result<ExecResult, SqlxError>> receiveItem(
    String returnId,
    String itemId,
    int quantity,
    int damagedQuantity,
  );

  /// Restores intact units when the historical item still has managed stock.
  @Query(r'''
UPDATE product_variants
SET inventory_quantity = inventory_quantity + $3
WHERE manage_inventory = 1 AND deleted_at IS NULL AND $3 > 0
  AND id = (
    SELECT order_item.variant_id
    FROM return_items returned
    JOIN order_items order_item ON order_item.id = returned.order_item_id
    WHERE returned.return_id = $1 AND returned.id = $2
  )
''')
  Future<Result<ExecResult, SqlxError>> restoreStock(
    String returnId,
    String itemId,
    int quantity,
  );

  /// Derives terminal or partial status after every item update succeeds.
  @Query(r'''
UPDATE return_requests
SET status = CASE WHEN EXISTS (
      SELECT 1 FROM return_items item
      WHERE item.return_id = $1 AND item.received_quantity < item.quantity
    ) THEN 'partially_received' ELSE 'received' END,
    received_at = coalesce(
      received_at, strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
    ),
    no_notification = $2
WHERE id = $1 AND deleted_at IS NULL
  AND status IN ('requested', 'partially_received')
''')
  Future<Result<ExecResult, SqlxError>> finish(
    String returnId,
    int noNotification,
  );
}
