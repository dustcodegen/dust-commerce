part of 'admin_order_detail.dart';

/// Explicit optional values decoded from nullable order JSON fields.
extension AdminOrderDetailOptions on AdminOrderDetail {
  /// Billing destination, absent only for legacy snapshots.
  Option<AdminOrderAddress> get billingAddress =>
      adminOptionOf(billingAddressValue);

  /// Amount recorded by the provider adapter, when present.
  Option<int> get paymentAmount => adminOptionOf(paymentAmountValue);

  /// Stable payment route id, absent before payment starts.
  Option<String> get paymentId => adminOptionOf(paymentIdValue);

  /// Provider capture instant, when funds moved.
  Option<DateTime> get paymentCapturedAt =>
      adminOptionOf(paymentCapturedAtValue);

  /// Provider record creation instant, when present.
  Option<DateTime> get paymentCreatedAt => adminOptionOf(paymentCreatedAtValue);

  /// Public payment adapter identifier, when present.
  Option<String> get paymentProvider => adminOptionOf(paymentProviderValue);

  /// Provider payment record lifecycle, when present.
  Option<AdminOrderPaymentRecordStatus> get paymentRecordStatus =>
      adminOptionOf(paymentRecordStatusValue);

  /// Applied promotion code, when one was frozen.
  Option<String> get promotionCode => adminOptionOf(promotionCodeValue);

  /// Shipping destination, absent only for legacy snapshots.
  Option<AdminOrderAddress> get shippingAddress =>
      adminOptionOf(shippingAddressValue);

  /// Selected delivery label, when one was frozen.
  Option<String> get shippingName => adminOptionOf(shippingNameValue);

  /// Original shipping method selected during checkout.
  Option<String> get shippingOptionId => adminOptionOf(shippingOptionIdValue);
}
