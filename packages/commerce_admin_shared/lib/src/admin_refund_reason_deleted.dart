import 'package:dust_dart/serde.dart';

part 'admin_refund_reason_deleted.g.dart';

/// Acknowledgement returned after retiring one refund reason.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminRefundReasonDeleted with _$AdminRefundReasonDeleted {
  /// Creates one retirement acknowledgement.
  const AdminRefundReasonDeleted({required this.id, required this.deleted});

  /// Decodes one generated Admin response.
  factory AdminRefundReasonDeleted.fromJson(Map<String, Object?> json) =>
      _$AdminRefundReasonDeletedFromJson(json);

  /// Whether the active row was retired.
  final bool deleted;

  /// Retired reason id.
  final String id;
}
