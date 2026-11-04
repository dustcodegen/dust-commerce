import 'package:intl/intl.dart';

/// Returns the ISO 4217 exponent used by [currencyCode].
int currencyDecimalDigits(String currencyCode) =>
    NumberFormat.simpleCurrency(name: currencyCode.toUpperCase())
        .decimalDigits ??
    2;

/// Formats exact integer [amount] for a merchant price field.
String formatMinorUnits(int amount, String currencyCode) {
  final digits = currencyDecimalDigits(currencyCode);
  if (digits == 0) return amount.toString();
  final scale = _powerOfTen(digits);
  final major = amount ~/ scale;
  final minor = (amount % scale).toString().padLeft(digits, '0');
  return '$major.$minor';
}

/// Parses a merchant price without a floating-point conversion.
int? parseMinorUnits(String value, String currencyCode) {
  final digits = currencyDecimalDigits(currencyCode);
  final decimal = digits == 0 ? '' : '(?:\\.(\\d{1,$digits}))?';
  final match = RegExp('^(\\d+)$decimal\$').firstMatch(value.trim());
  if (match == null) return null;
  final major = int.tryParse(match.group(1)!);
  if (major == null) return null;
  final fraction = digits == 0
      ? 0
      : int.tryParse((match.group(2) ?? '').padRight(digits, '0')) ?? 0;
  return major * _powerOfTen(digits) + fraction;
}

int _powerOfTen(int exponent) {
  var value = 1;
  for (var index = 0; index < exponent; index++) {
    value *= 10;
  }
  return value;
}
