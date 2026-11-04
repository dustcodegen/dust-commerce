import 'package:commerce_shared/commerce_shared.dart';

/// Formats exact minor-unit money at the display edge.
String formatMoney(Money amount) {
  final major = amount.amount ~/ 100;
  final minor = (amount.amount % 100).toString().padLeft(2, '0');
  return '${amount.currencyCode.toUpperCase()} $major.$minor';
}
