import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_dart/db.dart';
import 'package:dust_dart/serde.dart';

part 'model.g.dart';

/// Owned order facts required before any return item is accepted.
@Derive([FromRow()])
final class OrderReturnCandidate {
  /// Creates order eligibility facts directly from SQL.
  const OrderReturnCandidate({required this.paymentStatus});

  /// Payment must be captured before physical goods can be returned.
  @Sqlx(rename: 'payment_status')
  final String paymentStatus;
}

/// Delivered line quantity and units already claimed by returns.
@Derive([FromRow()])
final class OrderReturnItemCandidate {
  /// Creates item availability facts directly from SQL.
  const OrderReturnItemCandidate({
    required this.id,
    required this.deliveredQuantity,
    required this.claimedQuantity,
  });

  /// Delivered units already present in any non-canceled return.
  @Sqlx(rename: 'claimed_quantity')
  final int claimedQuantity;

  /// Units delivered by active fulfillment records.
  @Sqlx(rename: 'delivered_quantity')
  final int deliveredQuantity;

  /// Immutable order-item identifier.
  final String id;
}

/// Explicit Store response allowlist decoded directly from SQLx.
@Derive([FromRow(), Serialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class OrderReturnResponse with _$OrderReturnResponse {
  /// Creates a persisted return acknowledgement.
  const OrderReturnResponse({
    required this.id,
    required this.displayId,
    required this.orderId,
    required this.status,
    required this.itemQuantity,
    required this.requestedAt,
  });

  /// Short customer-facing request number.
  @Sqlx(rename: 'display_id')
  final int displayId;

  /// Stable opaque return identifier.
  final String id;

  /// Total requested units across every item.
  @Sqlx(rename: 'item_quantity')
  final int itemQuantity;

  /// Owned order associated with this request.
  @Sqlx(rename: 'order_id')
  final String orderId;

  /// Database-generated UTC request instant.
  @Sqlx(rename: 'requested_at')
  final DateTime requestedAt;

  /// Typed lifecycle decoded from the stored Medusa-compatible value.
  @SerDe(using: _OrderReturnStatusCodec())
  @Sqlx(tryFrom: _OrderReturnStatusSqlx())
  final OrderReturnStatus status;
}

/// Explicit active Store return reason populated directly from SQLx.
@Derive([FromRow(), Serialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class ReturnReasonResponse with _$ReturnReasonResponse {
  /// Creates one customer-safe reason allowlist.
  const ReturnReasonResponse({
    required this.id,
    required this.value,
    required this.label,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.parentReturnReasonId,
  });

  /// When the merchant created this reason.
  @Sqlx(rename: 'created_at')
  final DateTime createdAt;

  /// Optional customer guidance.
  final String? description;

  /// Stable identifier accepted by a return item.
  final String id;

  /// Customer-facing reason label.
  final String label;

  /// Optional parent used to group the taxonomy.
  @Sqlx(rename: 'parent_return_reason_id')
  final String? parentReturnReasonId;

  /// When the merchant last changed this reason.
  @Sqlx(rename: 'updated_at')
  final DateTime updatedAt;

  /// Stable machine value retained across label edits.
  final String value;
}

/// Paginated Store return-reason response.
@Derive([Serialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class ReturnReasonListResponse with _$ReturnReasonListResponse {
  /// Creates one complete active reason page.
  const ReturnReasonListResponse({
    required this.returnReasons,
    required this.count,
    required this.limit,
    required this.offset,
  });

  /// Total active reasons matching this list.
  final int count;

  /// Maximum rows requested for this page.
  final int limit;

  /// Number of active rows skipped before this page.
  final int offset;

  /// Explicit customer-safe reason allowlists.
  final List<ReturnReasonResponse> returnReasons;
}

final class _OrderReturnStatusCodec
    implements SerDeCodec<OrderReturnStatus, String> {
  const _OrderReturnStatusCodec();

  @override
  OrderReturnStatus deserialize(String value) => _status(value);

  @override
  String serialize(OrderReturnStatus value) => _statusName(value);
}

final class _OrderReturnStatusSqlx
    implements SqlxTryFrom<OrderReturnStatus, String> {
  const _OrderReturnStatusSqlx();

  @override
  OrderReturnStatus decode(String value) => _status(value);
}

OrderReturnStatus _status(String value) => switch (value) {
      'open' => OrderReturnStatus.open,
      'requested' => OrderReturnStatus.requested,
      'received' => OrderReturnStatus.received,
      'partially_received' => OrderReturnStatus.partiallyReceived,
      'canceled' => OrderReturnStatus.canceled,
      _ => throw ArgumentError.value(value, 'value', 'Unknown return status'),
    };

String _statusName(OrderReturnStatus value) => switch (value) {
      OrderReturnStatus.open => 'open',
      OrderReturnStatus.requested => 'requested',
      OrderReturnStatus.received => 'received',
      OrderReturnStatus.partiallyReceived => 'partially_received',
      OrderReturnStatus.canceled => 'canceled',
    };
