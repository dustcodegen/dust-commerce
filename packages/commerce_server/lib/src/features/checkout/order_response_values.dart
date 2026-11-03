part of 'model.dart';

/// Public values derived from the direct SQLx order response.
extension OrderResponseValues on OrderResponse {
  /// Billing destination decoded from the query aggregate.
  Address get billingAddress => _orderAddress(billingAddressJson);

  /// Customer owner, absent for guest checkout.
  String? get customerId => orderCustomerId;

  /// Contact email captured at checkout.
  String get email => orderEmail;

  /// Stable order identifier.
  String get id => orderId;

  /// Customer-visible progress from active fulfillment records.
  OrderFulfillmentStatus get fulfillmentStatus =>
      OrderFulfillmentStatusCodec().deserialize(storedFulfillmentStatus);

  /// Current payment lifecycle.
  PaymentStatus get paymentStatus => PaymentStatus.values.firstWhere(
        (status) => status.name == storedPaymentStatus,
        orElse: () => PaymentStatus.awaiting,
      );

  /// Safe payment receipt once provider authorization has started.
  OrderPaymentResponse? get payment {
    final provider = paymentProvider;
    final amount = paymentAmount;
    final createdAt = paymentCreatedAt;
    if (provider == null || amount == null || createdAt == null) return null;
    return OrderPaymentResponse(
      providerId: provider,
      amount: _money(amount),
      createdAt: createdAt,
    );
  }

  /// Explicit region response captured with the order.
  RegionResponse get region => RegionResponse(
        id: regionId,
        name: regionName,
        currencyCode: currencyCode,
        taxRate: regionTaxRate,
        countries: regionCountries,
        taxInclusive: regionTaxInclusive,
      );

  /// Shipping destination decoded from the query aggregate.
  Address get shippingAddress => _orderAddress(shippingAddressJson);

  /// Current order lifecycle.
  OrderStatus get status => OrderStatus.values.firstWhere(
        (status) => status.name == storedStatus,
        orElse: () => OrderStatus.pending,
      );

  /// Frozen discount amount.
  Money get discountTotal => _money(orderDiscountTotal);

  /// Explicit frozen shipping method, when selected.
  ShippingMethodResponse? get shippingMethod => shippingOptionId == null
      ? null
      : ShippingMethodResponse(
          optionId: shippingOptionId!,
          name: shippingName ?? 'Delivery',
          amount: shippingTotal,
        );

  /// Frozen delivery amount.
  Money get shippingTotal => _money(orderShippingTotal);

  /// Frozen goods subtotal.
  Money get subtotal => _money(orderSubtotal);

  /// Frozen tax amount.
  Money get tax => _money(orderTax);

  /// Frozen charged amount.
  Money get total => _money(orderTotal);

  Money _money(int amount) => Money(amount: amount, currencyCode: currencyCode);

  /// Returns the response state after payment capture only.
  OrderResponse captured() => OrderResponse(
        orderId: orderId,
        displayId: displayId,
        orderEmail: orderEmail,
        orderCustomerId: orderCustomerId,
        currencyCode: currencyCode,
        orderSubtotal: orderSubtotal,
        orderShippingTotal: orderShippingTotal,
        orderDiscountTotal: orderDiscountTotal,
        orderTax: orderTax,
        orderTotal: orderTotal,
        storedStatus: storedStatus,
        storedFulfillmentStatus: storedFulfillmentStatus,
        storedPaymentStatus: PaymentStatus.captured.name,
        placedAt: placedAt,
        regionId: regionId,
        regionName: regionName,
        regionTaxRate: regionTaxRate,
        regionTaxInclusive: regionTaxInclusive,
        regionCountries: regionCountries,
        items: items,
        shippingAddressJson: shippingAddressJson,
        billingAddressJson: billingAddressJson,
        paymentAmount: paymentAmount,
        paymentCreatedAt: paymentCreatedAt,
        paymentProvider: paymentProvider,
        shippingOptionId: shippingOptionId,
        shippingName: shippingName,
      );
}

Map<String, Object?> _serializeOrderResponse(OrderResponse value) =>
    <String, Object?>{
      'id': value.id,
      'display_id': value.displayId,
      'email': value.email,
      'customer_id': value.customerId,
      'region': value.region,
      'items': value.items,
      'subtotal': value.subtotal,
      'shipping_total': value.shippingTotal,
      'discount_total': value.discountTotal,
      'shipping_method': value.shippingMethod,
      'tax': value.tax,
      'total': value.total,
      'shipping_address': value.shippingAddress,
      'billing_address': value.billingAddress,
      'placed_at': value.placedAt,
      'payment': value.payment,
      'status': value.status.name,
      'fulfillment_status': value.storedFulfillmentStatus,
      'payment_status': value.paymentStatus.name,
    };

Address _orderAddress(String source) =>
    Address.fromJson(jsonDecode(source) as Map<String, Object?>);

List<OrderLineItemResponse> _decodeOrderLineItems(String source) => [
      for (final item in jsonDecode(source) as List<Object?>)
        OrderLineItemResponse.fromJson(item! as Map<String, Object?>),
    ];
