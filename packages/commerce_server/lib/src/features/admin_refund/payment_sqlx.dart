part of 'payment_model.dart';

final class _AdminRefundDateTimeFromString
    implements SqlxTryFrom<DateTime, DateTime> {
  const _AdminRefundDateTimeFromString();

  @override
  DateTime decode(DateTime value) => value.toUtc();
}

final class _AdminRefundPaymentStatusFromString
    implements SqlxTryFrom<AdminOrderPaymentRecordStatus, String> {
  const _AdminRefundPaymentStatusFromString();

  @override
  AdminOrderPaymentRecordStatus decode(String value) =>
      const AdminOrderPaymentRecordStatusCodec().deserialize(value);
}

final class _AdminRefundsFromString
    implements SqlxTryFrom<List<AdminRefund>, String> {
  const _AdminRefundsFromString();

  @override
  List<AdminRefund> decode(String value) => (jsonDecode(value) as List<Object?>)
      .map((item) => AdminRefund.fromJson(item! as Map<String, Object?>))
      .toList(growable: false);
}
