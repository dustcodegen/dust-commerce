import 'dart:convert';

import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin_return/item_response.dart';
import 'package:dust_dart/db.dart';
import 'package:dust_dart/serde.dart';

part 'model.g.dart';

/// One Admin return populated directly from an explicit SQL projection.
@Derive([Serialize(), FromRow()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminReturnResponse with _$AdminReturnResponse {
  /// Creates one allowlisted merchant return response.
  const AdminReturnResponse({
    required this.id,
    required this.orderId,
    required this.displayId,
    required this.status,
    required this.noNotification,
    required this.refundAmount,
    required this.requestedAt,
    required this.receivedAt,
    required this.canceledAt,
    required this.createdAt,
    required this.updatedAt,
    required this.items,
  });

  /// Cancellation audit instant when the request was canceled.
  @Sqlx(rename: 'canceled_at', defaultValue: null, tryFrom: _ReturnDateTime())
  final DateTime? canceledAt;

  /// Database-generated creation instant.
  @Sqlx(rename: 'created_at', tryFrom: _ReturnDateTime())
  final DateTime createdAt;

  /// Short merchant-facing return number.
  @Sqlx(rename: 'display_id')
  final int displayId;

  /// Stable opaque return identifier.
  final String id;

  /// Requested quantities and merchant receipt progress.
  @Sqlx(rename: 'items_json', tryFrom: _ReturnItems())
  final List<AdminReturnItemResponse> items;

  /// Notification suppression retained without provider internals.
  @Sqlx(rename: 'no_notification')
  final bool noNotification;

  /// Frozen order associated with this return.
  @Sqlx(rename: 'order_id')
  final String orderId;

  /// Receipt audit instant after at least one unit was received.
  @Sqlx(rename: 'received_at', defaultValue: null, tryFrom: _ReturnDateTime())
  final DateTime? receivedAt;

  /// Accepted refund in minor units when decided.
  @Sqlx(rename: 'refund_amount')
  final int? refundAmount;

  /// Customer submission instant.
  @Sqlx(rename: 'requested_at', tryFrom: _ReturnDateTime())
  final DateTime requestedAt;

  /// Current Medusa-compatible return lifecycle.
  @SerDe(using: AdminReturnStatusCodec())
  @Sqlx(tryFrom: _ReturnStatus())
  final AdminReturnStatus status;

  /// Database-generated last mutation instant.
  @Sqlx(rename: 'updated_at', tryFrom: _ReturnDateTime())
  final DateTime updatedAt;
}

/// Return rows plus bounded-list metadata.
@Derive([Serialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminReturnListResponse with _$AdminReturnListResponse {
  /// Creates one merchant return page.
  const AdminReturnListResponse({
    required this.returns,
    required this.count,
    required this.limit,
    required this.offset,
  });

  /// Total matching active returns.
  final int count;

  /// Maximum requested page size.
  final int limit;

  /// Number of matching rows skipped.
  final int offset;

  /// Explicit direct-SQLx return responses.
  final List<AdminReturnResponse> returns;
}

final class _ReturnDateTime implements SqlxTryFrom<DateTime, DateTime> {
  const _ReturnDateTime();

  @override
  DateTime decode(DateTime value) => value.toUtc();
}

final class _ReturnItems
    implements SqlxTryFrom<List<AdminReturnItemResponse>, String> {
  const _ReturnItems();

  @override
  List<AdminReturnItemResponse> decode(String value) =>
      (jsonDecode(value) as List<Object?>)
          .map((item) => AdminReturnItemResponse.fromJson(
                item! as Map<String, Object?>,
              ))
          .toList(growable: false);
}

final class _ReturnStatus implements SqlxTryFrom<AdminReturnStatus, String> {
  const _ReturnStatus();

  @override
  AdminReturnStatus decode(String value) =>
      const AdminReturnStatusCodec().deserialize(value);
}
