import 'package:dust_dart/db.dart';
import 'package:dust_dart/serde.dart';

part 'reason_model.g.dart';

/// Active refund reason populated directly from the protected list query.
@Derive([Serialize(), FromRow()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminRefundReasonResponse with _$AdminRefundReasonResponse {
  /// Creates one explicit merchant reason response.
  const AdminRefundReasonResponse({
    required this.id,
    required this.label,
    required this.code,
    required this.description,
  });

  /// Stable machine code used for reconciliation.
  final String code;

  /// Optional merchant guidance.
  final String? description;

  /// Stable opaque reason identifier.
  final String id;

  /// Merchant-facing reason label.
  final String label;
}

/// One bounded page serialized directly by the Admin reason handler.
@Derive([Serialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminRefundReasonListResponse with _$AdminRefundReasonListResponse {
  /// Creates one explicit reason page.
  const AdminRefundReasonListResponse({
    required this.refundReasons,
    required this.count,
    required this.limit,
    required this.offset,
  });

  /// Total active matching reasons.
  final int count;

  /// Maximum records requested.
  final int limit;

  /// Matching records skipped.
  final int offset;

  /// Active rows in stable merchant-facing order.
  final List<AdminRefundReasonResponse> refundReasons;
}
