import 'package:commerce_admin_shared/src/admin_option.dart';
import 'package:commerce_admin_shared/src/admin_refund_reason.dart';
import 'package:dust_dart/serde.dart';

part 'admin_refund.g.dart';

/// One immutable refund event returned only to authenticated Admin clients.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminRefund with _$AdminRefund {
  /// Creates one explicit refund audit response.
  const AdminRefund({
    required this.id,
    required this.amount,
    required this.refundReasonValue,
    required this.noteValue,
    required this.createdByValue,
    required this.createdAt,
  });

  /// Decodes one generated Admin response.
  factory AdminRefund.fromJson(Map<String, Object?> json) =>
      _$AdminRefundFromJson(json);

  /// Refunded amount in the payment currency's minor unit.
  final int amount;

  /// Database-owned refund event instant.
  final DateTime createdAt;

  /// Nullable JSON backing for [createdBy].
  @SerDe(rename: 'created_by')
  final String? createdByValue;

  /// Stable opaque refund identifier.
  final String id;

  /// Nullable JSON backing for [note].
  @SerDe(rename: 'note')
  final String? noteValue;

  /// Nullable JSON backing for [refundReason].
  @SerDe(rename: 'refund_reason')
  final AdminRefundReason? refundReasonValue;

  /// Authenticated actor retained when the Admin account still exists.
  Option<String> get createdBy => adminOptionOf(createdByValue);

  /// Optional staff context without nullable state in the application layer.
  Option<String> get note => adminOptionOf(noteValue);

  /// Optional reason snapshot exposed without nullable widget state.
  Option<AdminRefundReason> get refundReason =>
      adminOptionOf(refundReasonValue);
}
