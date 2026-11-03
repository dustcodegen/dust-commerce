import 'package:commerce_server/src/features/admin_order/export_headers.dart';
import 'package:commerce_server/src/features/admin_order/export_model.dart';
import 'package:intl/intl.dart';

/// Flattens direct order/item projections into one RFC 4180 CSV document.
String adminOrderCsv(List<AdminOrderExportRow> rows) {
  final values = <List<String>>[
    adminOrderExportHeaders,
    for (final row in rows)
      [
        for (final header in adminOrderExportHeaders)
          _values(row)[header] ?? '',
      ],
  ];
  return '${values.map(_csvRow).join('\r\n')}\r\n';
}

Map<String, String> _values(AdminOrderExportRow row) {
  final itemTotal = row.itemUnitAmount == null || row.itemQuantity == null
      ? ''
      : _money(row.itemUnitAmount! * row.itemQuantity!, row.currencyCode);
  return {
    'Order Id': row.orderId,
    'Display Id': '${row.displayId}',
    'Status': row.status,
    'Payment Status': row.paymentStatus,
    'Fulfillment Status': row.fulfillmentStatus,
    'Created At': row.createdAt.toIso8601String(),
    'Updated At': row.updatedAt.toIso8601String(),
    'Email': row.email,
    'Customer Name': row.customerName,
    'Currency Code': row.currencyCode.toUpperCase(),
    'Subtotal': _money(row.subtotal, row.currencyCode),
    'Shipping Total': _money(row.shippingTotal, row.currencyCode),
    'Discount Total': _money(row.discountTotal, row.currencyCode),
    'Tax Total': _money(row.taxTotal, row.currencyCode),
    'Total': _money(row.total, row.currencyCode),
    'Shipping Method': _text(row.shippingName),
    'Promotion Code': _text(row.promotionCode),
    'Item Id': _text(row.itemId),
    'Item Title': _text(row.itemTitle),
    'Item Variant': _text(row.itemVariantTitle),
    'Item Quantity': _text(row.itemQuantity),
    'Item Unit Price': _optionalMoney(row.itemUnitAmount, row.currencyCode),
    'Item Total': itemTotal,
    'Shipping Name': _text(row.shippingRecipient),
    'Shipping Company': _text(row.shippingCompany),
    'Shipping Address 1': _text(row.shippingLine1),
    'Shipping Address 2': _text(row.shippingLine2),
    'Shipping City': _text(row.shippingCity),
    'Shipping Province': _text(row.shippingProvince),
    'Shipping Postal Code': _text(row.shippingPostalCode),
    'Shipping Country Code': _country(row.shippingCountryCode),
    'Shipping Phone': _text(row.shippingPhone),
    'Billing Name': _text(row.billingRecipient),
    'Billing Company': _text(row.billingCompany),
    'Billing Address 1': _text(row.billingLine1),
    'Billing Address 2': _text(row.billingLine2),
    'Billing City': _text(row.billingCity),
    'Billing Province': _text(row.billingProvince),
    'Billing Postal Code': _text(row.billingPostalCode),
    'Billing Country Code': _country(row.billingCountryCode),
    'Billing Phone': _text(row.billingPhone),
    'Payment Provider': _text(row.paymentProvider),
    'Payment Amount': _optionalMoney(row.paymentAmount, row.currencyCode),
    'Payment Record Status': _text(row.paymentRecordStatus),
    'Payment Captured At': _text(row.paymentCapturedAt),
  };
}

String _money(int amount, String currency) {
  final digits = NumberFormat.simpleCurrency(
        name: currency.toUpperCase(),
      ).decimalDigits ??
      2;
  var divisor = 1;
  for (var index = 0; index < digits; index++) {
    divisor *= 10;
  }
  if (digits == 0) return '$amount';
  final whole = amount ~/ divisor;
  final remainder = (amount % divisor).toString().padLeft(digits, '0');
  return '$whole.$remainder';
}

String _optionalMoney(int? amount, String currency) =>
    amount == null ? '' : _money(amount, currency);

String _country(String? value) => value?.toUpperCase() ?? '';

String _text(Object? value) => value?.toString() ?? '';

String _csvRow(List<String> values) => values.map(_escape).join(',');

String _escape(String value) => value.contains(RegExp('[,"\r\n]'))
    ? '"${value.replaceAll('"', '""')}"'
    : value;
