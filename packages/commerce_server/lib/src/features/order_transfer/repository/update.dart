import 'package:dust_dart/db.dart';

part 'update.g.dart';

/// SQL transitions for transfer decisions and email delivery leases.
@SqlxDao()
abstract final class OrderTransferUpdateRepository {
  /// Binds transfer updates to [db].
  const factory OrderTransferUpdateRepository(Executor db) =
      _$OrderTransferUpdateRepository;

  /// Expires an undecided request and destroys any unsent raw capability.
  @Query(r'''
UPDATE order_transfers
SET status = 'expired', decided_at = $2,
    delivery_status = CASE
      WHEN delivery_status = 'sent' THEN 'sent' ELSE 'cancelled' END,
    delivery_token = NULL, delivery_lease_until = NULL
WHERE order_id = $1 AND status = 'requested' AND expires_at <= $2
''')
  Future<Result<ExecResult, SqlxError>> expire(String orderId, String now);

  /// Claims queued work or recovers a lease abandoned by a crashed sender.
  @Query(r'''
UPDATE order_transfers
SET delivery_status = 'sending', delivery_lease_until = $3,
    delivery_attempts = delivery_attempts + 1,
    last_delivery_error = NULL
WHERE id = $1 AND status = 'requested'
  AND (
    delivery_status = 'queued' OR
    (delivery_status = 'sending' AND delivery_lease_until <= $2)
  )
''')
  Future<Result<ExecResult, SqlxError>> claimDelivery(
    String id,
    String now,
    String leaseUntil,
  );

  /// Records SMTP acceptance and removes the raw capability from storage.
  @Query(r'''
UPDATE order_transfers
SET delivery_status = 'sent', delivery_token = NULL,
    delivery_lease_until = NULL, sent_at = $2, last_delivery_error = NULL
WHERE id = $1 AND status = 'requested' AND delivery_status = 'sending'
''')
  Future<Result<ExecResult, SqlxError>> markDelivered(String id, String now);

  /// Releases failed SMTP work so a later customer retry can reclaim it.
  @Query(r'''
UPDATE order_transfers
SET delivery_status = 'queued', delivery_lease_until = NULL,
    last_delivery_error = $2
WHERE id = $1 AND status = 'requested' AND delivery_status = 'sending'
''')
  Future<Result<ExecResult, SqlxError>> releaseDelivery(
    String id,
    String error,
  );

  /// Moves the order to the transfer target while it remains mutable.
  @Query(r'''
UPDATE orders
SET customer_id = (SELECT customer_id FROM order_transfers WHERE id = $2)
WHERE id = $1 AND status <> 'canceled' AND deleted_at IS NULL
  AND EXISTS (
    SELECT 1 FROM order_transfers
    WHERE id = $2 AND order_id = $1 AND status = 'requested'
  )
''')
  Future<Result<ExecResult, SqlxError>> transferOrder(
    String orderId,
    String transferId,
  );

  /// Completes a still-requested ownership transfer.
  @Query(r'''
UPDATE order_transfers
SET status = 'accepted', decided_at = $2,
    delivery_status = CASE
      WHEN delivery_status = 'sent' THEN 'sent' ELSE 'cancelled' END,
    delivery_token = NULL, delivery_lease_until = NULL
WHERE id = $1 AND status = 'requested'
''')
  Future<Result<ExecResult, SqlxError>> accept(String id, String now);

  /// Rejects a still-requested ownership transfer without changing the order.
  @Query(r'''
UPDATE order_transfers
SET status = 'declined', decided_at = $2,
    delivery_status = CASE
      WHEN delivery_status = 'sent' THEN 'sent' ELSE 'cancelled' END,
    delivery_token = NULL, delivery_lease_until = NULL
WHERE id = $1 AND status = 'requested'
''')
  Future<Result<ExecResult, SqlxError>> decline(String id, String now);
}
