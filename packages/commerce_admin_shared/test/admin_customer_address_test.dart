import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:test/test.dart';

void main() {
  test('create address matches and normalizes the Medusa form contract', () {
    final input = AdminCreateCustomerAddress.fromJson({
      'address_name': '  Home  ',
      'address_1': '  12 St James Square  ',
      'address_2': ' ',
      'country_code': ' GB ',
      'city': '',
      'postal_code': null,
      'province': null,
      'company': null,
      'phone': null,
    });

    expect(input.addressName, 'Home');
    expect(input.line1, '12 St James Square');
    expect(input.line2, const None<String>());
    expect(input.countryCode, 'gb');
    expect(input.city, const None<String>());
    expect(input.validate().isValid, isTrue);
    expect(input.toJson().keys, {
      'address_name',
      'is_default_shipping',
      'is_default_billing',
      'company',
      'first_name',
      'last_name',
      'address_1',
      'address_2',
      'city',
      'country_code',
      'province',
      'postal_code',
      'phone',
    });
  });

  test('address response represents source-optional fields with Option', () {
    final address = AdminCustomerAddress.fromJson({
      'id': 'addr_home',
      'address_name': 'Home',
      'first_name': null,
      'last_name': null,
      'company': null,
      'phone': null,
      'address_1': '12 St James Square',
      'address_2': null,
      'city': null,
      'province': null,
      'postal_code': null,
      'country_code': 'gb',
      'is_default_shipping': false,
      'is_default_billing': false,
    });

    expect(address.addressName, const Some('Home'));
    expect(address.firstName, const None<String>());
    expect(address.city, const None<String>());
    expect(address.postalCode, const None<String>());
  });

  test('address deletion decodes the Medusa parent acknowledgement', () {
    final deleted = AdminCustomerAddressDeleted.fromJson({
      'id': 'addr_home',
      'object': 'customer_address',
      'deleted': true,
      'parent': {
        'id': 'cus_ada',
        'email': 'ada@example.com',
        'company_name': null,
        'first_name': 'Ada',
        'last_name': 'Lovelace',
        'phone': null,
        'has_account': true,
        'created_at': '2026-09-14T01:02:03.000Z',
        'updated_at': '2026-09-14T02:03:04.000Z',
        'addresses': const <Object?>[],
      },
    });

    expect(deleted.id, 'addr_home');
    expect(deleted.object, 'customer_address');
    expect(deleted.deleted, isTrue);
    expect(
        deleted.parent.map((customer) => customer.id), const Some('cus_ada'));
    expect(deleted.toJson().keys, {'id', 'object', 'deleted', 'parent'});
  });
}
