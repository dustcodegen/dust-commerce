import 'package:commerce_admin_shared/src/admin_order_status.dart';
import 'package:commerce_admin_shared/src/admin_option.dart';
import 'package:dust_dart/serde.dart';

part 'admin_order.g.dart';

/// One explicitly allowlisted row in the merchant order table.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminOrder with _$AdminOrder {
  /// Creates one immutable merchant order summary.
  const AdminOrder({
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
    required this.salesChannelNameValue,
    this.countryCode,
  });

  /// Decodes the generated Admin response.
  factory AdminOrder.fromJson(Map<String, Object?> json) =>
      _$AdminOrderFromJson(json);

  /// Shipping destination country when the order has one.
  final String? countryCode;

  /// Nullable JSON backing for [salesChannelName].
  @SerDe(rename: 'sales_channel_name')
  final String? salesChannelNameValue;

  /// Merchant-facing commercial origin, absent for legacy orders.
  Option<String> get salesChannelName => adminOptionOf(salesChannelNameValue);

  /// Database-generated order creation instant.
  final DateTime createdAt;

  /// Lowercase ISO 4217 currency for [total].
  final String currencyCode;

  /// Human-readable customer identity with guest email fallback.
  final String customerName;

  /// Short monotonically increasing merchant order number.
  final int displayId;

  /// Contact email frozen at checkout.
  final String email;

  /// Current fulfilment state represented by this schema.
  @SerDe(using: AdminOrderFulfillmentStatusCodec())
  final AdminOrderFulfillmentStatus fulfillmentStatus;

  /// Opaque order identifier used by detail routes.
  final String id;

  /// Current payment state.
  @SerDe(using: AdminOrderPaymentStatusCodec())
  final AdminOrderPaymentStatus paymentStatus;

  /// Current order lifecycle state.
  @SerDe(using: AdminOrderStatusCodec())
  final AdminOrderStatus status;

  /// Exact order total in the currency's minor unit.
  final int total;

  /// Database-generated last mutation instant.
  final DateTime updatedAt;
}

/// One bounded page returned by the merchant order API.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminOrderList with _$AdminOrderList {
  /// Creates a merchant order page.
  const AdminOrderList({
    required this.orders,
    required this.count,
    required this.limit,
    required this.offset,
  });

  /// Decodes the generated list response.
  factory AdminOrderList.fromJson(Map<String, Object?> json) =>
      _$AdminOrderListFromJson(json);

  /// Total orders matching the active query.
  final int count;

  /// Maximum rows requested for this page.
  final int limit;

  /// Number of matching rows skipped.
  final int offset;

  /// Immutable order summaries in stable requested order.
  final List<AdminOrder> orders;
}
