import 'dart:convert';

import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/db.dart';
import 'package:dust_dart/serde.dart';

part 'payment_model.g.dart';
part 'payment_sqlx.dart';

/// Payment and order facts required before an independent refund write.
@Derive([FromRow()])
final class AdminPaymentRefundTarget {
  /// Creates the direct SQLx validation projection.
  const AdminPaymentRefundTarget({
    required this.paymentId,
    required this.orderId,
    required this.providerId,
    required this.amount,
    required this.currencyCode,
    required this.paymentRecordStatus,
    required this.orderPaymentStatus,
    required this.capturedAt,
    required this.refundedAmount,
  });

  /// Original payment amount in minor units.
  final int amount;

  /// Capture time must exist before funds can be returned.
  @Sqlx(
    rename: 'captured_at',
    defaultValue: null,
  )
  final DateTime? capturedAt;

  /// Frozen lowercase ISO 4217 currency.
  @Sqlx(rename: 'currency_code')
  final String currencyCode;

  /// Parent order used for the aggregate payment-status update.
  @Sqlx(rename: 'order_id')
  final String orderId;

  /// Order-level payment status used to detect reconciliation drift.
  @Sqlx(rename: 'order_payment_status')
  final String orderPaymentStatus;

  /// Stable route identifier for the one-payment collection.
  @Sqlx(rename: 'payment_id')
  final String paymentId;

  /// Provider lifecycle used independently from order status.
  @Sqlx(rename: 'payment_record_status')
  final String paymentRecordStatus;

  /// Public adapter id; provider-private metadata is never projected.
  @Sqlx(rename: 'provider_id')
  final String providerId;

  /// Sum of active refund audits already committed.
  @Sqlx(rename: 'refunded_amount')
  final int refundedAmount;
}

/// Refreshed Admin payment response populated directly from SQLx.
@Derive([Serialize(), FromRow()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminRefundedPaymentResponse with _$AdminRefundedPaymentResponse {
  /// Creates the explicit response without provider-private fields.
  const AdminRefundedPaymentResponse({
    required this.id,
    required this.providerId,
    required this.amount,
    required this.refundedAmount,
    required this.currencyCode,
    required this.status,
    required this.capturedAt,
    required this.refunds,
  });

  /// Original captured amount in minor units.
  final int amount;

  /// Provider capture instant.
  @Sqlx(rename: 'captured_at')
  final DateTime capturedAt;

  /// Lowercase ISO 4217 currency shared by every refund.
  @Sqlx(rename: 'currency_code')
  final String currencyCode;

  /// Stable payment id accepted by the refund route.
  final String id;

  /// Public payment adapter id.
  @Sqlx(rename: 'provider_id')
  final String providerId;

  /// Total active refund amount in minor units.
  @Sqlx(rename: 'refunded_amount')
  final int refundedAmount;

  /// Ordered immutable refund history.
  @Sqlx(rename: 'refunds_json', tryFrom: _AdminRefundsFromString())
  final List<AdminRefund> refunds;

  /// Provider payment lifecycle remains captured after a refund.
  @SerDe(using: AdminOrderPaymentRecordStatusCodec())
  @Sqlx(tryFrom: _AdminRefundPaymentStatusFromString())
  final AdminOrderPaymentRecordStatus status;
}
