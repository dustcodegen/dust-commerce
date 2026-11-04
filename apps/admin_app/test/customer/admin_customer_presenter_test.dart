import 'package:admin_app/src/customer/admin_customer_presenter.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('presents only the supplied customer name parts', () {
    expect(adminCustomerName(_customer(first: 'Ada', last: 'Lovelace')),
        'Ada Lovelace');
    expect(adminCustomerName(_customer(first: 'Ada')), 'Ada');
    expect(adminCustomerName(_customer(last: 'Lovelace')), 'Lovelace');
    expect(adminCustomerName(_customer()), '—');
  });

  test('presents account state with Medusa labels', () {
    expect(adminCustomerAccount(_customer(hasAccount: true)), 'Registered');
    expect(adminCustomerAccount(_customer()), 'Guest');
  });

  test('presents detail and address absence without nullable UI checks', () {
    final detail = _detail();

    expect(adminCustomerDetailName(detail), 'Ada Lovelace');
    expect(adminCustomerDetailText(detail.companyName), '—');
    expect(adminCustomerAddressTitle(detail.addresses.single), 'Ada Lovelace');
    expect(
      adminCustomerAddressLines(detail.addresses.single),
      '12 St James Square\nLondon, SW1Y 4LB\nGB',
    );
  });
}

AdminCustomer _customer({
  String? first,
  String? last,
  bool hasAccount = false,
}) =>
    AdminCustomer(
      id: 'cus_test',
      emailValue: null,
      firstNameValue: first,
      lastNameValue: last,
      hasAccount: hasAccount,
      createdAt: DateTime.utc(2026, 9, 14),
      updatedAt: DateTime.utc(2026, 9, 14),
    );

AdminCustomerDetail _detail() => AdminCustomerDetail(
      id: 'cus_ada',
      emailValue: 'ada@example.com',
      companyNameValue: null,
      firstNameValue: 'Ada',
      lastNameValue: 'Lovelace',
      phoneValue: null,
      hasAccount: true,
      createdAt: DateTime.utc(2026, 9, 14),
      updatedAt: DateTime.utc(2026, 9, 14),
      addresses: const [
        AdminCustomerAddress(
          id: 'addr_ada',
          addressNameValue: null,
          firstNameValue: 'Ada',
          lastNameValue: 'Lovelace',
          line1: '12 St James Square',
          cityValue: 'London',
          postalCodeValue: 'SW1Y 4LB',
          countryCode: 'gb',
          isDefaultShipping: true,
          isDefaultBilling: false,
          companyValue: null,
          phoneValue: null,
          line2Value: null,
          provinceValue: null,
        ),
      ],
    );
