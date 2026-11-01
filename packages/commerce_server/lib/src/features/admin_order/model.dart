import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/db.dart';
import 'package:dust_dart/serde.dart';

part 'model.g.dart';

/// One order-table response populated directly from its SQL projection.
@Derive([Serialize(), FromRow()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminOrderResponse with _$AdminOrderResponse {
  /// Creates an explicitly allowlisted merchant order row.
  const AdminOrderResponse({
    required this.id,
    required this.displayId,
    required this.createdAt,
    required this.updatedAt,
    required this.email,
    required this.customerName,
    required this.status,
    required this.paymentStatus,
    required this.fulfillmentStatus,
    required this.total,
    required this.currencyCode,
    this.countryCode,
    this.salesChannelName,
  });

  /// Shipping destination country when an address exists.
  @Sqlx(rename: 'country_code')
  final String? countryCode;

  /// Merchant-facing commercial origin, absent for legacy orders.
  @Sqlx(rename: 'sales_channel_name')
  final String? salesChannelName;

  /// Database-generated creation instant decoded from PostgreSQL TIMESTAMPTZ.
  @Sqlx(rename: 'created_at', tryFrom: _AdminOrderUtcDateTime())
  final DateTime createdAt;

  /// Lowercase ISO 4217 currency for [total].
  @Sqlx(rename: 'currency_code')
  final String currencyCode;

  /// Customer display value with the immutable order email as fallback.
  @Sqlx(rename: 'customer_name')
  final String customerName;

  /// Short merchant-facing order number.
  @Sqlx(rename: 'display_id')
  final int displayId;

  /// Immutable order contact email.
  final String email;

  /// Current fulfilment status supported by this schema.
  @SerDe(using: AdminOrderFulfillmentStatusCodec())
  @Sqlx(
    rename: 'fulfillment_status',
    tryFrom: _AdminOrderFulfillmentStatusSqlx(),
  )
  final AdminOrderFulfillmentStatus fulfillmentStatus;

  /// Stable opaque order identifier.
  final String id;

  /// Current payment state.
  @SerDe(using: AdminOrderPaymentStatusCodec())
  @Sqlx(rename: 'payment_status', tryFrom: _AdminOrderPaymentStatusSqlx())
  final AdminOrderPaymentStatus paymentStatus;

  /// Current order lifecycle state.
  @SerDe(using: AdminOrderStatusCodec())
  @Sqlx(tryFrom: _AdminOrderStatusSqlx())
  final AdminOrderStatus status;

  /// Exact frozen total in minor units.
  final int total;

  /// Database-generated mutation instant decoded from PostgreSQL TIMESTAMPTZ.
  @Sqlx(rename: 'updated_at', tryFrom: _AdminOrderUtcDateTime())
  final DateTime updatedAt;
}

/// Order rows plus bounded-list metadata.
@Derive([Serialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminOrderListResponse with _$AdminOrderListResponse {
  /// Creates one merchant order page.
  const AdminOrderListResponse({
    required this.orders,
    required this.count,
    required this.limit,
    required this.offset,
  });

  /// Total rows matching the active query.
  final int count;

  /// Maximum requested page size.
  final int limit;

  /// Number of matching rows skipped.
  final int offset;

  /// Explicit direct SQLx order summaries.
  final List<AdminOrderResponse> orders;
}

final class _AdminOrderUtcDateTime implements SqlxTryFrom<DateTime, String> {
  const _AdminOrderUtcDateTime();

  @override
  DateTime decode(String value) => DateTime.parse(value).toUtc();
}

final class _AdminOrderStatusSqlx
    implements SqlxTryFrom<AdminOrderStatus, String> {
  const _AdminOrderStatusSqlx();

  @override
  AdminOrderStatus decode(String value) =>
      const AdminOrderStatusCodec().deserialize(value);
}

final class _AdminOrderPaymentStatusSqlx
    implements SqlxTryFrom<AdminOrderPaymentStatus, String> {
  const _AdminOrderPaymentStatusSqlx();

  @override
  AdminOrderPaymentStatus decode(String value) =>
      const AdminOrderPaymentStatusCodec().deserialize(value);
}

final class _AdminOrderFulfillmentStatusSqlx
    implements SqlxTryFrom<AdminOrderFulfillmentStatus, String> {
  const _AdminOrderFulfillmentStatusSqlx();

  @override
  AdminOrderFulfillmentStatus decode(String value) =>
      const AdminOrderFulfillmentStatusCodec().deserialize(value);
}
