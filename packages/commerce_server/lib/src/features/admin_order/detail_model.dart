import 'dart:convert';
// ignore_for_file: public_member_api_docs

import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin_order/detail_address_response.dart';
import 'package:commerce_server/src/features/admin_order/detail_item_response.dart';
import 'package:commerce_server/src/features/admin_order/fulfillment_response.dart';
import 'package:dust_dart/db.dart';
import 'package:dust_dart/serde.dart';

part 'detail_model.g.dart';
part 'detail_sqlx.dart';

/// Complete Admin response populated directly from one SQLx projection.
@Derive([Serialize(), FromRow()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminOrderDetailResponse with _$AdminOrderDetailResponse {
  /// Creates the explicit merchant response without a domain-model conversion.
  const AdminOrderDetailResponse({
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
    required this.shippingName,
    required this.shippingOptionId,
    required this.promotionCode,
    required this.placedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.items,
    required this.fulfillments,
    required this.shippingAddress,
    required this.billingAddress,
    required this.paymentProvider,
    required this.paymentId,
    required this.paymentAmount,
    required this.paymentRefundedAmount,
    required this.paymentRefunds,
    required this.paymentRecordStatus,
    required this.paymentCreatedAt,
    required this.paymentCapturedAt,
  });

  /// Billing destination, absent only for legacy snapshots.
  @Sqlx(
    rename: 'billing_address_json',
    defaultValue: null,
    tryFrom: _AdminOrderAddressFromString(),
  )
  final AdminOrderAddressResponse? billingAddress;

  @Sqlx(rename: 'created_at', tryFrom: _AdminOrderDateTime())
  final DateTime createdAt;

  @Sqlx(rename: 'currency_code')
  final String currencyCode;

  @Sqlx(rename: 'customer_name')
  final String customerName;

  @Sqlx(rename: 'discount_total')
  final int discountTotal;

  @Sqlx(rename: 'display_id')
  final int displayId;

  final String email;

  /// Fulfilment state represented by the current schema.
  @SerDe(using: AdminOrderFulfillmentStatusCodec())
  @Sqlx(
    rename: 'fulfillment_status',
    tryFrom: _AdminOrderFulfillmentStatusFromString(),
  )
  final AdminOrderFulfillmentStatus fulfillmentStatus;

  final String id;

  /// Active fulfillment records and their frozen item snapshots.
  @Sqlx(rename: 'fulfillments_json', tryFrom: _AdminFulfillmentsFromString())
  final List<AdminOrderFulfillmentResponse> fulfillments;

  /// Frozen line-item snapshots in creation order.
  @Sqlx(rename: 'items_json', tryFrom: _AdminOrderItemsFromString())
  final List<AdminOrderItemResponse> items;

  @Sqlx(rename: 'region_id')
  final String regionId;

  @Sqlx(rename: 'payment_amount')
  final int? paymentAmount;

  /// Stable payment route id, absent before payment starts.
  @Sqlx(rename: 'payment_id')
  final String? paymentId;

  /// Sum of active refund audits in minor units.
  @Sqlx(rename: 'payment_refunded_amount')
  final int paymentRefundedAmount;

  /// Ordered independent refund history kept outside Store contracts.
  @Sqlx(rename: 'payment_refunds_json', tryFrom: _AdminOrderRefundsFromString())
  final List<AdminRefund> paymentRefunds;

  @Sqlx(
    rename: 'payment_captured_at',
    defaultValue: null,
    tryFrom: _AdminOrderDateTime(),
  )
  final DateTime? paymentCapturedAt;

  @Sqlx(
    rename: 'payment_created_at',
    defaultValue: null,
    tryFrom: _AdminOrderDateTime(),
  )
  final DateTime? paymentCreatedAt;

  @Sqlx(rename: 'payment_provider')
  final String? paymentProvider;

  @SerDe(using: AdminOrderPaymentRecordStatusCodec())
  @Sqlx(
    rename: 'payment_record_status',
    defaultValue: null,
    tryFrom: _AdminOrderPaymentRecordStatusFromString(),
  )
  final AdminOrderPaymentRecordStatus? paymentRecordStatus;

  @SerDe(using: AdminOrderPaymentStatusCodec())
  @Sqlx(
    rename: 'payment_status',
    tryFrom: _AdminOrderPaymentStatusFromString(),
  )
  final AdminOrderPaymentStatus paymentStatus;

  @Sqlx(rename: 'placed_at', tryFrom: _AdminOrderDateTime())
  final DateTime placedAt;

  @Sqlx(rename: 'promotion_code')
  final String? promotionCode;

  /// Shipping destination, absent only for legacy snapshots.
  @Sqlx(
    rename: 'shipping_address_json',
    defaultValue: null,
    tryFrom: _AdminOrderAddressFromString(),
  )
  final AdminOrderAddressResponse? shippingAddress;

  @Sqlx(rename: 'shipping_name')
  final String? shippingName;

  @Sqlx(rename: 'shipping_option_id')
  final String? shippingOptionId;

  @Sqlx(rename: 'shipping_total')
  final int shippingTotal;

  @SerDe(using: AdminOrderStatusCodec())
  @Sqlx(tryFrom: _AdminOrderStatusFromString())
  final AdminOrderStatus status;
  final int subtotal;
  final int tax;
  final int total;

  @Sqlx(rename: 'updated_at', tryFrom: _AdminOrderDateTime())
  final DateTime updatedAt;
}

final class _AdminOrderDateTime
    implements SqlxTryFrom<DateTime, DateTime> {
  const _AdminOrderDateTime();

  @override
  DateTime decode(DateTime value) => value.toUtc();
}
