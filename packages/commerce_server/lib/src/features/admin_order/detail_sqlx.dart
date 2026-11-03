part of 'detail_model.dart';

final class _AdminOrderAddressFromString
    implements SqlxTryFrom<AdminOrderAddressResponse, String> {
  const _AdminOrderAddressFromString();

  @override
  AdminOrderAddressResponse decode(String value) =>
      AdminOrderAddressResponse.fromJson(
        jsonDecode(value) as Map<String, Object?>,
      );
}

final class _AdminOrderItemsFromString
    implements SqlxTryFrom<List<AdminOrderItemResponse>, String> {
  const _AdminOrderItemsFromString();

  @override
  List<AdminOrderItemResponse> decode(String value) =>
      (jsonDecode(value) as List<Object?>)
          .map((item) =>
              AdminOrderItemResponse.fromJson(item! as Map<String, Object?>))
          .toList(growable: false);
}

final class _AdminFulfillmentsFromString
    implements SqlxTryFrom<List<AdminOrderFulfillmentResponse>, String> {
  const _AdminFulfillmentsFromString();

  @override
  List<AdminOrderFulfillmentResponse> decode(String value) =>
      (jsonDecode(value) as List<Object?>)
          .map((item) => AdminOrderFulfillmentResponse.fromJson(
                item! as Map<String, Object?>,
              ))
          .toList(growable: false);
}

final class _AdminOrderRefundsFromString
    implements SqlxTryFrom<List<AdminRefund>, String> {
  const _AdminOrderRefundsFromString();

  @override
  List<AdminRefund> decode(String value) => (jsonDecode(value) as List<Object?>)
      .map((item) => AdminRefund.fromJson(item! as Map<String, Object?>))
      .toList(growable: false);
}

final class _AdminOrderPaymentRecordStatusFromString
    implements SqlxTryFrom<AdminOrderPaymentRecordStatus, String> {
  const _AdminOrderPaymentRecordStatusFromString();

  @override
  AdminOrderPaymentRecordStatus decode(String value) =>
      AdminOrderPaymentRecordStatus.values.byName(value);
}

final class _AdminOrderStatusFromString
    implements SqlxTryFrom<AdminOrderStatus, String> {
  const _AdminOrderStatusFromString();

  @override
  AdminOrderStatus decode(String value) =>
      const AdminOrderStatusCodec().deserialize(value);
}

final class _AdminOrderPaymentStatusFromString
    implements SqlxTryFrom<AdminOrderPaymentStatus, String> {
  const _AdminOrderPaymentStatusFromString();

  @override
  AdminOrderPaymentStatus decode(String value) =>
      const AdminOrderPaymentStatusCodec().deserialize(value);
}

final class _AdminOrderFulfillmentStatusFromString
    implements SqlxTryFrom<AdminOrderFulfillmentStatus, String> {
  const _AdminOrderFulfillmentStatusFromString();

  @override
  AdminOrderFulfillmentStatus decode(String value) =>
      const AdminOrderFulfillmentStatusCodec().deserialize(value);
}
