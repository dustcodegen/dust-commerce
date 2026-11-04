import 'package:commerce_admin_shared/src/admin_option.dart';
import 'package:dust_dart/serde.dart';

part 'admin_refund_reason.g.dart';

/// Merchant-managed reason available to an independent payment refund.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminRefundReason with _$AdminRefundReason {
  /// Creates one explicit Admin refund-reason response.
  const AdminRefundReason({
    required this.id,
    required this.label,
    required this.code,
    required this.descriptionValue,
  });

  /// Decodes one generated Admin response.
  factory AdminRefundReason.fromJson(Map<String, Object?> json) =>
      _$AdminRefundReasonFromJson(json);

  /// Stable machine code used for reconciliation and reporting.
  final String code;

  /// Optional merchant guidance backing [description].
  @SerDe(rename: 'description')
  final String? descriptionValue;

  /// Stable opaque reason identifier accepted by refund commands.
  final String id;

  /// Merchant-facing reason shown in the refund form and history.
  final String label;

  /// Optional merchant guidance without exposing nullable state to widgets.
  Option<String> get description => adminOptionOf(descriptionValue);
}

/// One bounded page from Medusa's protected refund-reason API.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminRefundReasonList with _$AdminRefundReasonList {
  /// Creates one generated-client page.
  const AdminRefundReasonList({
    required this.refundReasons,
    required this.count,
    required this.limit,
    required this.offset,
  });

  /// Decodes one generated Admin response.
  factory AdminRefundReasonList.fromJson(Map<String, Object?> json) =>
      _$AdminRefundReasonListFromJson(json);

  /// Total active reasons matching the query.
  final int count;

  /// Maximum records requested for this page.
  final int limit;

  /// Matching records skipped before this page.
  final int offset;

  /// Active reasons in stable label order.
  final List<AdminRefundReason> refundReasons;
}
