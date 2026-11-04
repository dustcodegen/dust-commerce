import 'dart:convert';

import 'package:commerce_server/src/features/cart/model/model.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_dart/db.dart';
import 'package:dust_dart/serde.dart';

import 'order_item_response.dart';
import 'order_payment_response.dart';

export 'order_list_response.dart';

part 'model.g.dart';
part 'order_response_values.dart';

/// Complete order response populated directly by one SQLx query.
///
/// Serialization is an explicit allowlist. This class does not inherit the
/// domain order, so new internal order fields cannot appear on the wire.
@Derive([FromRow()])
final class OrderResponse implements Serializable {
  /// Constructs the final response directly from frozen database values.
  OrderResponse({
    required this.orderId,
    required this.displayId,
    required this.orderEmail,
    required this.currencyCode,
    required this.orderSubtotal,
    required this.orderShippingTotal,
    required this.orderDiscountTotal,
    required this.orderTax,
    required this.orderTotal,
    required this.storedStatus,
    required this.storedFulfillmentStatus,
    required this.storedPaymentStatus,
    required this.placedAt,
    required this.regionId,
    required this.regionName,
    required this.regionTaxRate,
    required this.regionTaxInclusive,
    required this.regionCountries,
    required this.items,
    required this.shippingAddressJson,
    required this.billingAddressJson,
    this.orderCustomerId,
    this.paymentAmount,
    this.paymentCreatedAt,
    this.paymentProvider,
    this.shippingOptionId,
    this.shippingName,
    required this.shippingFulfillmentType,
    this.shippingPickupAddress,
    this.shippingPickupName,
  });

  /// Billing address encoded by SQLite's JSON functions.
  @Sqlx(rename: 'billing_address_json')
  final String billingAddressJson;

  /// Currency shared by every frozen monetary amount.
  @Sqlx(rename: 'currency_code')
  final String currencyCode;

  /// Immutable order lines decoded directly by the SQLx row response.
  @Sqlx(rename: 'items_json', tryFrom: OrderLineItemsFromJson())
  final List<OrderLineItemResponse> items;

  /// Customer owner when the order was not placed as a guest.
  @Sqlx(rename: 'customer_id')
  final String? orderCustomerId;

  /// Contact email captured at checkout.
  @Sqlx(rename: 'email')
  final String orderEmail;

  /// Short monotonically increasing identifier shown to people.
  @Sqlx(rename: 'display_id')
  final int displayId;

  /// Stable order identifier.
  @Sqlx(rename: 'id')
  final String orderId;

  /// Authorised payment amount, absent before payment begins.
  @Sqlx(rename: 'payment_amount')
  final int? paymentAmount;

  /// Provider record creation time, absent before payment begins.
  @Sqlx(
    rename: 'payment_created_at',
    defaultValue: null,
    tryFrom: _PostgresDateTime(),
  )
  final DateTime? paymentCreatedAt;

  /// Public provider identifier, absent before payment begins.
  @Sqlx(rename: 'payment_provider')
  final String? paymentProvider;

  /// Frozen discount in integer minor units.
  @Sqlx(rename: 'discount_total')
  final int orderDiscountTotal;

  /// Frozen delivery amount in integer minor units.
  @Sqlx(rename: 'shipping_total')
  final int orderShippingTotal;

  /// Frozen goods subtotal in integer minor units.
  @Sqlx(rename: 'subtotal')
  final int orderSubtotal;

  /// Frozen tax in integer minor units.
  @Sqlx(rename: 'tax')
  final int orderTax;

  /// Frozen charged amount in integer minor units.
  @Sqlx(rename: 'total')
  final int orderTotal;

  /// Placement timestamp stored as a UTC instant.
  @Sqlx(rename: 'placed_at', tryFrom: _PostgresDateTime())
  final DateTime placedAt;

  /// Region country codes decoded from PostgreSQL's text array.
  @Sqlx(rename: 'countries')
  final List<String> regionCountries;

  /// Region identifier captured by the order.
  @Sqlx(rename: 'region_id')
  final String regionId;

  /// Region display name.
  @Sqlx(rename: 'region_name')
  final String regionName;

  /// Whether the frozen region prices included tax.
  @Sqlx(rename: 'tax_inclusive')
  final bool regionTaxInclusive;

  /// Region tax rate in basis points.
  @Sqlx(rename: 'tax_rate')
  final int regionTaxRate;

  /// Shipping address encoded by SQLite's JSON functions.
  @Sqlx(rename: 'shipping_address_json')
  final String shippingAddressJson;

  /// Delivery service name captured at checkout.
  @Sqlx(rename: 'shipping_name')
  final String? shippingName;

  /// Fulfillment kind captured from the selected shipping option.
  @Sqlx(
    rename: 'shipping_fulfillment_type',
    tryFrom: ShippingFulfillmentTypeFromSql(),
  )
  @SerDe(using: ShippingFulfillmentTypeCodec())
  final ShippingFulfillmentType shippingFulfillmentType;

  /// Delivery option captured at checkout.
  @Sqlx(rename: 'shipping_option_id')
  final String? shippingOptionId;

  /// Pickup address captured from the selected option, when applicable.
  @Sqlx(rename: 'shipping_pickup_address')
  final String? shippingPickupAddress;

  /// Pickup store captured from the selected option, when applicable.
  @Sqlx(rename: 'shipping_pickup_name')
  final String? shippingPickupName;

  /// Payment lifecycle value stored in SQLite.
  @Sqlx(rename: 'payment_status')
  final String storedPaymentStatus;

  /// Fulfillment lifecycle derived by the order query.
  @Sqlx(rename: 'fulfillment_status')
  final String storedFulfillmentStatus;

  /// Order lifecycle value stored in SQLite.
  @Sqlx(rename: 'status')
  final String storedStatus;

  @override
  Map<String, Object?> serialize() => _serializeOrderResponse(this);

  @override
  Map<String, Object?> toJson() => serialize();
}

/// Converts the SQL order-item aggregate directly into response DTOs.
final class OrderLineItemsFromJson
    implements SqlxTryFrom<List<OrderLineItemResponse>, String> {
  /// Creates the stateless aggregate decoder.
  const OrderLineItemsFromJson();

  @override
  List<OrderLineItemResponse> decode(String value) =>
      _decodeOrderLineItems(value);
}

/// Normalizes PostgreSQL TIMESTAMPTZ values at the row boundary.
final class _PostgresDateTime implements SqlxTryFrom<DateTime, DateTime> {
  const _PostgresDateTime();

  @override
  DateTime decode(DateTime value) => value.toUtc();
}
