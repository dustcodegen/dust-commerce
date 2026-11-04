import 'package:commerce_admin_shared/src/admin_option.dart';
import 'package:commerce_admin_shared/src/admin_order_status.dart';
import 'package:commerce_admin_shared/src/admin_refund.dart';
import 'package:dust_dart/serde.dart';

part 'admin_refund_payment.g.dart';

/// Medusa-compatible body for refunding one captured payment.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase, disallowUnrecognizedKeys: true)
final class AdminRefundPayment with _$AdminRefundPayment {
  /// Creates one explicit command; omitted amount means all remaining funds.
  const AdminRefundPayment({
    this.amountValue,
    this.refundReasonIdValue,
    this.noteValue,
  });

  /// Decodes and rejects command keys outside the allowlist.
  factory AdminRefundPayment.fromJson(Map<String, Object?> json) =>
      _$AdminRefundPaymentFromJson(json);

  /// Nullable JSON backing for [amount].
  @SerDe(rename: 'amount')
  final int? amountValue;

  /// Nullable JSON backing for [note].
  @SerDe(rename: 'note')
  final String? noteValue;

  /// Nullable JSON backing for [refundReasonId].
  @SerDe(rename: 'refund_reason_id')
  final String? refundReasonIdValue;

  /// Custom minor-unit amount; absence means every remaining refundable unit.
  Option<int> get amount => adminOptionOf(amountValue);

  /// Optional staff context kept separate from the standardized reason.
  Option<String> get note => adminOptionOf(noteValue);

  /// Optional active merchant reason selected for this decision.
  Option<String> get refundReasonId => adminOptionOf(refundReasonIdValue);
}

/// Refreshed payment returned after one independent refund decision.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminRefundedPayment with _$AdminRefundedPayment {
  /// Creates one explicit payment response without exposing provider metadata.
  const AdminRefundedPayment({
    required this.id,
    required this.providerId,
    required this.amount,
    required this.refundedAmount,
    required this.currencyCode,
    required this.status,
    required this.capturedAt,
    required this.refunds,
  });

  /// Decodes one generated Admin response.
  factory AdminRefundedPayment.fromJson(Map<String, Object?> json) =>
      _$AdminRefundedPaymentFromJson(json);

  /// Original captured amount in minor units.
  final int amount;

  /// Capture instant required before refunding.
  final DateTime capturedAt;

  /// Lowercase ISO 4217 currency for every amount.
  final String currencyCode;

  /// Stable payment identifier used by the refund route.
  final String id;

  /// Public adapter identifier; private provider data is never serialized.
  final String providerId;

  /// Total active refunds in minor units.
  final int refundedAmount;

  /// Active refund audits in creation order.
  final List<AdminRefund> refunds;

  /// Provider payment lifecycle retained after partial and full refunds.
  @SerDe(using: AdminOrderPaymentRecordStatusCodec())
  final AdminOrderPaymentRecordStatus status;

  /// Amount that can still be safely refunded.
  int get refundableAmount => amount - refundedAmount;
}
