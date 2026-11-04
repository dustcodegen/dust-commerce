import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:test/test.dart';

void main() {
  test('address update keeps omitted and explicit null fields distinct', () {
    final update = AdminUpdateCustomerAddress.fromJson({
      'address_name': null,
      'country_code': ' GB ',
      'is_default_shipping': true,
    });

    expect(update.addressName, const Some<String?>(null));
    expect(update.line1, const None<String?>());
    expect(update.countryCode, const Some<String?>('gb'));
    expect(update.toJson(), {
      'address_name': null,
      'country_code': 'gb',
      'is_default_shipping': true,
    });
  });

  test('address update rejects empty, unknown, and invalid patches', () {
    for (final body in <Map<String, Object?>>[
      {},
      {'customer_id': 'cus_attacker'},
      {'address_1': null},
      {'country_code': 'Great Britain'},
      {'is_default_billing': 1},
    ]) {
      expect(
        () => AdminUpdateCustomerAddress.fromJson(body),
        throwsFormatException,
      );
    }
  });
}
