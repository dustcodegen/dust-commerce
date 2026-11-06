import 'package:commerce_server/src/features/admin_refund/payment_model.dart';
import 'package:dust_dart/db.dart';

part 'payment_repository.g.dart';

/// Transaction-scoped persistence for independent payment refunds.
@SqlxDao()
abstract final class AdminPaymentRefundRepository {
  /// Binds validation, write, and refreshed response queries to [db].
  const factory AdminPaymentRefundRepository(Executor db) =
      _$AdminPaymentRefundRepository;

  /// Locks the same order row as cancellation before reading the balance.
  @Query(r'''
SELECT order_row.id
FROM orders order_row
JOIN payment_collections payment ON payment.order_id = order_row.id
WHERE payment.id = $1 AND payment.deleted_at IS NULL
  AND order_row.deleted_at IS NULL
FOR UPDATE OF order_row
''')
  Future<Result<String?, SqlxError>> lockOrderForPayment(String paymentId);

  /// Reads payment and aggregate refund facts before the first write.
  @Query(r'''
SELECT payment.id AS payment_id, payment.order_id, payment.provider AS provider_id,
       payment.amount, payment.currency_code,
       payment.status AS payment_record_status, payment.captured_at,
       order_row.payment_status AS order_payment_status,
       coalesce((SELECT sum(refund.amount) FROM refunds refund
                 WHERE refund.payment_collection_id = payment.id
                   AND refund.deleted_at IS NULL), 0) AS refunded_amount
FROM payment_collections payment
JOIN orders order_row ON order_row.id = payment.order_id
WHERE payment.id = $1 AND payment.deleted_at IS NULL
  AND order_row.deleted_at IS NULL
''')
  Future<Result<AdminPaymentRefundTarget?, SqlxError>> target(String paymentId);

  /// Confirms an optional reason is active before recording its foreign key.
  @Query(r'''
SELECT count(*) FROM refund_reasons
WHERE id = $1 AND deleted_at IS NULL
''')
  Future<Result<int, SqlxError>> activeReasonCount(String reasonId);

  /// Writes one auditable refund; PostgreSQL owns the event timestamp.
  @Query(r'''
INSERT INTO refunds (
  id, payment_collection_id, amount, currency_code,
  refund_reason_id, note, created_by
) VALUES ($1, $2, $3, $4, $5, $6, $7)
''')
  Future<Result<ExecResult, SqlxError>> insert(
    String id,
    String paymentId,
    int amount,
    String currencyCode,
    String? reasonId,
    String? note,
    String adminId,
  );

  /// Marks the aggregate order refunded only after all funds are returned.
  @Query(r'''
UPDATE orders SET payment_status = 'refunded'
WHERE id = $1 AND payment_status = 'captured' AND deleted_at IS NULL
''')
  Future<Result<ExecResult, SqlxError>> markOrderRefunded(String orderId);

  /// Returns the Medusa-shaped payment with active refund audits.
  @Query(r'''
SELECT payment.id, payment.provider AS provider_id, payment.amount,
       payment.currency_code, payment.status,
       payment.captured_at AS "captured_at!",
       coalesce((SELECT sum(refund.amount) FROM refunds refund
                 WHERE refund.payment_collection_id = payment.id
                   AND refund.deleted_at IS NULL), 0) AS refunded_amount,
       coalesce((SELECT json_agg(json_build_object(
         'id', refund.id, 'amount', refund.amount,
         'refund_reason', CASE WHEN refund.reason_id IS NULL THEN NULL ELSE
           json_build_object('id', refund.reason_id, 'label', refund.reason_label,
                       'code', refund.reason_code,
                       'description', refund.reason_description) END,
         'note', refund.note, 'created_by', refund.created_by,
         'created_at', refund.created_at
       )) FROM (
         SELECT record.*, reason.id AS reason_id, reason.label AS reason_label,
                reason.code AS reason_code,
                reason.description AS reason_description
         FROM refunds record
         LEFT JOIN refund_reasons reason ON reason.id = record.refund_reason_id
         WHERE record.payment_collection_id = payment.id
           AND record.deleted_at IS NULL
         ORDER BY record.created_at, record.id
       ) refund), '[]'::json)::text AS refunds_json
FROM payment_collections payment
WHERE payment.id = $1 AND payment.deleted_at IS NULL
''')
  Future<Result<AdminRefundedPaymentResponse?, SqlxError>> find(
      String paymentId);
}
