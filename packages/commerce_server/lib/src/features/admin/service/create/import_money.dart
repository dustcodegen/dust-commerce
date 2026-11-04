import 'package:intl/intl.dart';

/// Converts a validated decimal to exact ISO-4217 integer minor units.
int? adminImportMinorUnits(String value, String currencyCode) {
  final digits = NumberFormat.simpleCurrency(name: currencyCode.toUpperCase())
          .decimalDigits ??
      2;
  final parts = value.split('.');
  if (parts.length > 2 || parts.first.isEmpty) return null;
  final fraction = parts.length == 1 ? '' : parts.last;
  if (fraction.length > digits) return null;
  try {
    final factor = _powerOfTen(digits);
    final whole = int.parse(parts.first);
    final minor =
        fraction.isEmpty ? 0 : int.parse(fraction.padRight(digits, '0'));
    final amount = whole * factor + minor;
    return amount <= 9223372036854775807 ? amount : null;
  } on FormatException {
    return null;
  }
}

int _powerOfTen(int exponent) {
  var value = 1;
  for (var index = 0; index < exponent; index++) {
    value *= 10;
  }
  return value;
}
