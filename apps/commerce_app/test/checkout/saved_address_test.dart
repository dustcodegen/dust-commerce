import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('saved checkout addresses are region scoped and copied into a draft',
      () {
    const us = CustomerAddressView(
      id: 'addr_us',
      firstName: 'Ada',
      lastName: 'Lovelace',
      line1: '12 Analytical Way',
      city: 'Washington',
      province: 'DC',
      postalCode: '20001',
      countryCode: 'US',
      phone: '+1 555 0101',
      company: 'Analytical Engines',
      isDefaultShipping: true,
      isDefaultBilling: false,
    );
    const dk = CustomerAddressView(
      id: 'addr_dk',
      firstName: 'Ada',
      lastName: 'Lovelace',
      line1: '1 Other Street',
      city: 'Copenhagen',
      postalCode: '1000',
      countryCode: 'dk',
      isDefaultShipping: false,
      isDefaultBilling: false,
    );
    const state = AddressBookState(addresses: [us, dk]);

    expect(state.shippingAddressesFor(['us']), [us]);

    final draft = CheckoutAddressDraft.fromSavedAddress(us);
    expect(draft.countryCode, 'us');
    expect(draft.company, 'Analytical Engines');
    expect(draft.line2, isEmpty);
    expect(draft.matchesSavedAddress(us), isTrue);
    expect(draft.copyWith(city: 'Arlington').matchesSavedAddress(us), isFalse);
  });
}
