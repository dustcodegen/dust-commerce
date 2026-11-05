import 'package:commerce_server/src/features/admin_order/cancel_order_model.dart';
import 'package:dust_dart/db.dart';

part 'cancel_order_repository.g.dart';

/// Transaction-scoped persistence for whole-order cancellation.
@SqlxDao()
abstract final class AdminCancelOrderRepository {
  /// Binds validation, refund, inventory, and lifecycle writes to [db].
  const factory AdminCancelOrderRepository(Executor db) =
      _$AdminCancelOrderRepository;

  /// Reads every fact required before the first irreversible local write.
  @Query(r'''
SELECT order_row.status, order_row.payment_status, order_row.currency_code,
       payment.id AS payment_id, payment.provider AS payment_provider,
       payment.status AS payment_record_status,
       payment.amount AS payment_amount,
       coalesce((SELECT sum(refund.amount) FROM refunds refund
                 WHERE refund.payment_collection_id = payment.id
                   AND refund.deleted_at IS NULL), 0) AS refunded_amount,
       (SELECT count(*) FROM fulfillments fulfillment
        WHERE fulfillment.order_id = order_row.id
          AND fulfillment.deleted_at IS NULL
          AND fulfillment.canceled_at IS NULL) AS active_fulfillment_count
FROM orders order_row
LEFT JOIN payment_collections payment
  ON payment.order_id = order_row.id AND payment.deleted_at IS NULL
WHERE order_row.id = $1 AND order_row.deleted_at IS NULL
''')
  Future<Result<AdminCancelOrderTarget?, SqlxError>> target(String orderId);

  /// Makes the collection terminal after local cancel/refund work succeeds.
  @Query(r'''
UPDATE payment_collections SET status = 'canceled'
WHERE id = $1 AND deleted_at IS NULL AND status <> 'canceled'
''')
  Future<Result<ExecResult, SqlxError>> cancelPayment(String paymentId);

  /// Records one full refund; PostgreSQL owns its event timestamp.
  @Query(r'''
INSERT INTO refunds (
  id, payment_collection_id, amount, currency_code, created_by
) VALUES ($1, $2, $3, $4, $5)
''')
  Future<Result<ExecResult, SqlxError>> insertRefund(
    String id,
    String paymentId,
    int amount,
    String currencyCode,
    String adminId,
  );

  /// Releases the exact managed quantities reserved by this frozen order.
  @Query(r'''
UPDATE product_variants
SET inventory_quantity = inventory_quantity + (
  SELECT sum(item.quantity) FROM order_items item
  WHERE item.order_id = $1 AND item.variant_id = product_variants.id
)
WHERE manage_inventory = 1 AND EXISTS (
  SELECT 1 FROM order_items item
  WHERE item.order_id = $1 AND item.variant_id = product_variants.id
)
''')
  Future<Result<ExecResult, SqlxError>> releaseInventory(String orderId);

  /// Applies the terminal order state and audit using PostgreSQL's UTC clock.
  @Query(r'''
UPDATE orders
SET status = 'canceled', payment_status = $3,
    canceled_at = strftime('%Y-%m-%dT%H:%M:%fZ', 'now'), canceled_by = $2
WHERE id = $1 AND status = 'pending' AND deleted_at IS NULL
''')
  Future<Result<ExecResult, SqlxError>> cancelOrder(
    String orderId,
    String adminId,
    String paymentStatus,
  );
}
