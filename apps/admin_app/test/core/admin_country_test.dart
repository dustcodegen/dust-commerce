import 'package:admin_app/src/core/admin_country.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('shared Admin countries expose normalized ISO choices', () {
    expect(adminCountries.length, greaterThan(240));
    expect(adminCountryName('GB'), 'United Kingdom');
    expect(adminCountryName(null), '');
    expect(adminCountryName('zz'), 'ZZ');
  });

  test('country search matches names and codes', () {
    expect(
      adminCountryOptions(const TextEditingValue(text: 'united king'))
          .single
          .code,
      'gb',
    );
    expect(
      adminCountryOptions(const TextEditingValue(text: 'dk')).single.name,
      'Denmark',
    );
  });
}
