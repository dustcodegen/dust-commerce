import 'package:commerce_admin_shared/src/admin_option.dart';
import 'package:commerce_admin_shared/src/admin_order_address.dart';
import 'package:commerce_admin_shared/src/admin_order_item.dart';
import 'package:commerce_admin_shared/src/admin_order_fulfillment.dart';
import 'package:commerce_admin_shared/src/admin_order_status.dart';
import 'package:commerce_admin_shared/src/admin_refund.dart';
import 'package:dust_dart/serde.dart';

part 'admin_order_detail.g.dart';
part 'admin_order_detail_options.dart';

/// Complete read-only merchant view of one frozen order.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminOrderDetail with _$AdminOrderDetail {
  /// Creates the explicit Admin detail contract.
  const AdminOrderDetail({
    required this.id,
    required this.regionId,
    required this.displayId,
    required this.email,
    required this.customerName,
    required this.currencyCode,
    required this.subtotal,
    required this.shippingTotal,
    required this.discountTotal,
    required this.tax,
    required this.total,
    required this.status,
    required this.paymentStatus,
    required this.fulfillmentStatus,
    required this.shippingNameValue,
    required this.shippingOptionIdValue,
    required this.promotionCodeValue,
    required this.placedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.items,
    required this.fulfillments,
    required this.shippingAddressValue,
    required this.billingAddressValue,
    required this.paymentProviderValue,
    required this.paymentAmountValue,
    required this.paymentRecordStatusValue,
    required this.paymentCreatedAtValue,
    required this.paymentCapturedAtValue,
    this.paymentIdValue,
    this.paymentRefundedAmount = 0,
    this.paymentRefunds = const [],
  });

  /// Decodes one generated Admin order response.
  factory AdminOrderDetail.fromJson(Map<String, Object?> json) =>
      _$AdminOrderDetailFromJson(json);

  /// Nullable JSON backing for [billingAddress].
  @SerDe(rename: 'billing_address')
  final AdminOrderAddress? billingAddressValue;

  /// Database-generated order creation instant.
  final DateTime createdAt;

  /// Lowercase ISO 4217 currency for every amount.
  final String currencyCode;

  /// Human-readable customer identity with email fallback.
  final String customerName;

  /// Frozen discount in minor units.
  final int discountTotal;

  /// Short merchant-facing order number.
  final int displayId;

  /// Contact email frozen at checkout.
  final String email;

  /// Fulfilment state represented by the current schema.
  @SerDe(using: AdminOrderFulfillmentStatusCodec())
  final AdminOrderFulfillmentStatus fulfillmentStatus;

  /// Stable opaque order identifier.
  final String id;

  /// Selling region that constrains fulfillment shipping methods.
  final String regionId;

  /// Active fulfillment records and their frozen item snapshots.
  final List<AdminOrderFulfillment> fulfillments;

  /// Frozen line-item snapshots in creation order.
  final List<AdminOrderItem> items;

  /// Nullable JSON backing for [paymentAmount].
  @SerDe(rename: 'payment_amount')
  final int? paymentAmountValue;

  /// Nullable JSON backing for [paymentId].
  @SerDe(rename: 'payment_id')
  final String? paymentIdValue;

  /// Sum of active refund audits in minor units.
  @SerDe(defaultValue: 0)
  final int paymentRefundedAmount;

  /// Independent refund history visible only to Admin.
  @SerDe(defaultValue: <AdminRefund>[])
  final List<AdminRefund> paymentRefunds;

  /// Nullable JSON backing for [paymentCapturedAt].
  @SerDe(rename: 'payment_captured_at')
  final DateTime? paymentCapturedAtValue;

  /// Nullable JSON backing for [paymentCreatedAt].
  @SerDe(rename: 'payment_created_at')
  final DateTime? paymentCreatedAtValue;

  /// Nullable JSON backing for [paymentProvider].
  @SerDe(rename: 'payment_provider')
  final String? paymentProviderValue;

  /// Nullable JSON backing for [paymentRecordStatus].
  @SerDe(
    rename: 'payment_record_status',
    using: AdminOrderPaymentRecordStatusCodec(),
  )
  final AdminOrderPaymentRecordStatus? paymentRecordStatusValue;

  /// Order-level payment lifecycle.
  @SerDe(using: AdminOrderPaymentStatusCodec())
  final AdminOrderPaymentStatus paymentStatus;

  /// Business placement instant.
  final DateTime placedAt;

  /// Nullable JSON backing for [promotionCode].
  @SerDe(rename: 'promotion_code')
  final String? promotionCodeValue;

  /// Nullable JSON backing for [shippingAddress].
  @SerDe(rename: 'shipping_address')
  final AdminOrderAddress? shippingAddressValue;

  /// Nullable JSON backing for [shippingName].
  @SerDe(rename: 'shipping_name')
  final String? shippingNameValue;

  /// Nullable JSON backing for [shippingOptionId].
  @SerDe(rename: 'shipping_option_id')
  final String? shippingOptionIdValue;

  /// Frozen delivery amount in minor units.
  final int shippingTotal;

  /// Current order lifecycle.
  @SerDe(using: AdminOrderStatusCodec())
  final AdminOrderStatus status;

  /// Frozen goods subtotal in minor units.
  final int subtotal;

  /// Frozen tax amount in minor units.
  final int tax;

  /// Frozen charged total in minor units.
  final int total;

  /// Database-generated last mutation instant.
  final DateTime updatedAt;
}
