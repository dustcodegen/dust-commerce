import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:test/test.dart';

void main() {
  test('customer page decodes explicit absence and DateTime values', () {
    final page = AdminCustomerList.fromJson({
      'customers': [
        {
          'id': 'cus_guest',
          'email': 'guest@example.com',
          'first_name': null,
          'last_name': null,
          'has_account': false,
          'created_at': '2026-09-14T01:02:03.000Z',
          'updated_at': '2026-09-14T02:03:04.000Z',
        },
      ],
      'count': 1,
      'limit': 20,
      'offset': 0,
    });

    expect(page.customers.single.email, const Some('guest@example.com'));
    expect(page.customers.single.firstName, const None<String>());
    expect(page.customers.single.lastName, const None<String>());
    expect(page.customers.single.createdAt.isUtc, isTrue);
  });

  test('customer ordering accepts only the Medusa table allowlist', () {
    expect(
      AdminCustomerOrder.parse('-has_account'),
      const Some(AdminCustomerOrder.hasAccountDesc),
    );
    expect(AdminCustomerOrder.parse('metadata'), const None());
  });

  test('customer detail decodes only merchant-visible profile data', () {
    final customer = AdminCustomerDetail.fromJson({
      'id': 'cus_ada',
      'email': 'ada@example.com',
      'company_name': 'Analytical Engines',
      'first_name': 'Ada',
      'last_name': 'Lovelace',
      'phone': null,
      'has_account': true,
      'created_at': '2026-09-10T10:00:00.000Z',
      'updated_at': '2026-09-10T10:05:00.000Z',
      'addresses': [
        {
          'id': 'addr_home',
          'first_name': 'Ada',
          'last_name': 'Lovelace',
          'company': null,
          'phone': '+44 20 0000 0000',
          'address_1': '12 St James Square',
          'address_2': null,
          'city': 'London',
          'province': null,
          'postal_code': 'SW1Y 4LB',
          'country_code': 'gb',
          'is_default_shipping': true,
          'is_default_billing': false,
        },
      ],
    });

    expect(customer.companyName, const Some('Analytical Engines'));
    expect(customer.phone, const None<String>());
    expect(customer.addresses.single.line2, const None<String>());
    expect(customer.addresses.single.phone, const Some('+44 20 0000 0000'));
    expect(customer.createdAt.isUtc, isTrue);
    expect(customer.toJson().keys, {
      'id',
      'email',
      'company_name',
      'first_name',
      'last_name',
      'phone',
      'has_account',
      'created_at',
      'updated_at',
      'addresses',
    });
  });

  test('customer creation normalizes the source form allowlist', () {
    final input = AdminCreateCustomer.fromJson({
      'email': '  NEW.CUSTOMER@Example.com ',
      'first_name': 'Katherine',
      'last_name': 'Johnson',
      'company_name': null,
      'phone': '+1 202 555 0147',
    });

    expect(input.email, 'new.customer@example.com');
    expect(input.companyName, const None<String>());
    expect(input.firstName, const Some('Katherine'));
    expect(input.validate().isValid, isTrue);
    expect(input.toJson(), {
      'email': 'new.customer@example.com',
      'company_name': null,
      'first_name': 'Katherine',
      'last_name': 'Johnson',
      'phone': '+1 202 555 0147',
    });
    expect(
      AdminCreateCustomer(
        email: 'not-an-email',
        companyNameValue: null,
        firstNameValue: null,
        lastNameValue: null,
        phoneValue: null,
      ).validate().isValid,
      isFalse,
    );
  });

  test('customer edit preserves nullable clearing and guest email intent', () {
    final input = AdminUpdateCustomer.fromJson({
      'email': '  GUEST.NEW@Example.com ',
      'first_name': null,
      'last_name': 'Vaughan',
      'company_name': null,
      'phone': '+1 555 0102',
    });

    expect(input.email, const Some('guest.new@example.com'));
    expect(input.firstName, const None<String>());
    expect(input.validate().isValid, isTrue);
    expect(input.toJson(), {
      'email': 'guest.new@example.com',
      'company_name': null,
      'first_name': null,
      'last_name': 'Vaughan',
      'phone': '+1 555 0102',
    });
  });

  test('customer deletion decodes only the Medusa acknowledgement', () {
    final deleted = AdminCustomerDeleted.fromJson({
      'id': 'cus_guest',
      'object': 'customer',
      'deleted': true,
    });

    expect(deleted.id, 'cus_guest');
    expect(deleted.object, 'customer');
    expect(deleted.deleted, isTrue);
    expect(deleted.toJson().keys, {'id', 'object', 'deleted'});
  });
}
