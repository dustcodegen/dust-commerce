import 'package:admin_app/src/core/admin_money.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('uses the ISO 4217 exponent for merchant price input', () {
    expect(currencyDecimalDigits('jpy'), 0);
    expect(currencyDecimalDigits('usd'), 2);
    expect(currencyDecimalDigits('kwd'), 3);
  });

  test('formats integer minor units without floating-point conversion', () {
    expect(formatMinorUnits(1234, 'jpy'), '1234');
    expect(formatMinorUnits(1234, 'usd'), '12.34');
    expect(formatMinorUnits(1234, 'kwd'), '1.234');
  });

  test('parses exact decimal input using each currency exponent', () {
    expect(parseMinorUnits('1234', 'jpy'), 1234);
    expect(parseMinorUnits('12.34', 'usd'), 1234);
    expect(parseMinorUnits('1.234', 'kwd'), 1234);
    expect(parseMinorUnits('1.2', 'kwd'), 1200);
    expect(parseMinorUnits('1.23', 'jpy'), isNull);
    expect(parseMinorUnits('1.2345', 'kwd'), isNull);
  });
}
