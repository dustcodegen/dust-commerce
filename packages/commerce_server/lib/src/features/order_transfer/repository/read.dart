import 'package:commerce_server/src/features/order_transfer/model.dart';
import 'package:dust_dart/db.dart';

part 'read.g.dart';

/// SQL reads for order-transfer decisions and delivery.
@SqlxDao()
abstract final class OrderTransferReadRepository {
  /// Binds transfer reads to [db].
  const factory OrderTransferReadRepository(Executor db) =
      _$OrderTransferReadRepository;

  /// Order facts needed to decide whether a request is valid.
  @Query(r'''
SELECT id, customer_id, status
FROM orders
WHERE id = $1 AND deleted_at IS NULL
''')
  Future<Result<OrderTransferCandidate?, SqlxError>> candidate(String orderId);

  /// Target customer for the one active request on an order.
  @Query(r'''
SELECT customer_id
FROM order_transfers
WHERE order_id = $1 AND status = 'requested'
''')
  Future<Result<String?, SqlxError>> activeCustomer(String orderId);

  /// Minimal public response for the active request on one order.
  @Query(r'''
SELECT id, order_id, status, delivery_status, expires_at
FROM order_transfers
WHERE order_id = $1 AND status = 'requested'
''')
  Future<Result<OrderTransferResponse?, SqlxError>> activeResponse(
    String orderId,
  );

  /// Minimal public response for one transfer.
  @Query(r'''
SELECT id, order_id, status, delivery_status, expires_at
FROM order_transfers
WHERE id = $1
''')
  Future<Result<OrderTransferResponse?, SqlxError>> response(String id);

  /// Private raw capability after a sender successfully claims its lease.
  @Query(r'''
SELECT transfer.id, transfer.order_id, orders.email AS recipient_email,
       transfer.delivery_token AS "token!", transfer.expires_at
FROM order_transfers transfer
JOIN orders ON orders.id = transfer.order_id
WHERE transfer.id = $1
  AND transfer.status = 'requested'
  AND transfer.delivery_status = 'sending'
  AND transfer.delivery_token IS NOT NULL
  AND orders.deleted_at IS NULL
''')
  Future<Result<OrderTransferDelivery?, SqlxError>> delivery(String id);

  /// Transfer identified by an order and the presented token fingerprint.
  @Query(r'''
SELECT id, status
FROM order_transfers
WHERE order_id = $1 AND token_fingerprint = $2
''')
  Future<Result<OrderTransferDecisionRow?, SqlxError>> decision(
    String orderId,
    String tokenFingerprint,
  );
}
