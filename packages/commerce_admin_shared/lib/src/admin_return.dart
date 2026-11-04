import 'package:commerce_admin_shared/src/admin_option.dart';
import 'package:commerce_admin_shared/src/admin_return_item.dart';
import 'package:commerce_admin_shared/src/admin_return_status.dart';
import 'package:dust_dart/serde.dart';

part 'admin_return.g.dart';

/// Explicit Admin response for one customer return request.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminReturn with _$AdminReturn {
  /// Creates one merchant-visible return.
  const AdminReturn({
    required this.id,
    required this.orderId,
    required this.displayId,
    required this.status,
    required this.noNotification,
    required this.refundAmountValue,
    required this.requestedAt,
    required this.receivedAtValue,
    required this.canceledAtValue,
    required this.createdAt,
    required this.updatedAt,
    required this.items,
  });

  /// Decodes one generated Admin return response.
  factory AdminReturn.fromJson(Map<String, Object?> json) =>
      _$AdminReturnFromJson(json);

  /// Nullable JSON backing for [canceledAt].
  @SerDe(rename: 'canceled_at')
  final DateTime? canceledAtValue;

  /// Database-generated creation instant.
  final DateTime createdAt;

  /// Short merchant-facing return number.
  final int displayId;

  /// Stable opaque return identifier.
  final String id;

  /// Requested item quantities and merchant receipt progress.
  final List<AdminReturnItem> items;

  /// Whether provider notification should be suppressed.
  final bool noNotification;

  /// Frozen order associated with this return.
  final String orderId;

  /// Nullable JSON backing for [receivedAt].
  @SerDe(rename: 'received_at')
  final DateTime? receivedAtValue;

  /// Nullable JSON backing for [refundAmount].
  @SerDe(rename: 'refund_amount')
  final int? refundAmountValue;

  /// Customer submission instant.
  final DateTime requestedAt;

  /// Current merchant return lifecycle.
  @SerDe(using: AdminReturnStatusCodec())
  final AdminReturnStatus status;

  /// Database-generated last mutation instant.
  final DateTime updatedAt;

  /// Cancellation instant when the return was canceled.
  Option<DateTime> get canceledAt => adminOptionOf(canceledAtValue);

  /// Receipt instant after the merchant received at least one unit.
  Option<DateTime> get receivedAt => adminOptionOf(receivedAtValue);

  /// Accepted refund in minor units when one has been decided.
  Option<int> get refundAmount => adminOptionOf(refundAmountValue);
}
