import 'package:dust_dart/db.dart';

part 'cancel_order_model.g.dart';

/// Lifecycle, fulfillment, and payment facts for one cancellation decision.
@Derive([FromRow()])
final class AdminCancelOrderTarget {
  /// Creates the direct SQLx cancellation projection.
  const AdminCancelOrderTarget({
    required this.status,
    required this.paymentStatus,
    required this.currencyCode,
    required this.activeFulfillmentCount,
    required this.paymentId,
    required this.paymentProvider,
    required this.paymentRecordStatus,
    required this.paymentAmount,
    required this.refundedAmount,
  });

  /// Fulfillments that have not reached their canceled terminal state.
  @Sqlx(rename: 'active_fulfillment_count')
  final int activeFulfillmentCount;

  /// Frozen order currency used for a full captured-payment refund.
  @Sqlx(rename: 'currency_code')
  final String currencyCode;

  /// Provider amount absent when no collection has been created.
  @Sqlx(rename: 'payment_amount')
  final int? paymentAmount;

  /// Collection id absent before payment starts.
  @Sqlx(rename: 'payment_id')
  final String? paymentId;

  /// Payment adapter absent before payment starts.
  @Sqlx(rename: 'payment_provider')
  final String? paymentProvider;

  /// Collection lifecycle absent before payment starts.
  @Sqlx(rename: 'payment_record_status')
  final String? paymentRecordStatus;

  /// Active refunds already returned before cancellation.
  @Sqlx(rename: 'refunded_amount')
  final int refundedAmount;

  /// Order-level payment lifecycle used to validate reconciliation.
  @Sqlx(rename: 'payment_status')
  final String paymentStatus;

  /// Current order lifecycle.
  final String status;
}
