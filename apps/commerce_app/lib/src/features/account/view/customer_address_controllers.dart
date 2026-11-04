import 'package:commerce_shared/commerce_shared.dart';
import 'package:flutter/material.dart';

/// Text-editing resources for one customer-address form.
final class CustomerAddressControllers {
  /// Creates blank fields for Medusa's new-address form.
  CustomerAddressControllers.forNewAddress({String phone = ''})
      : this._(phone: phone);

  /// Creates fields prefilled from an existing address.
  CustomerAddressControllers.fromAddress(CustomerAddressView address)
      : this._(
          firstName: address.firstName,
          lastName: address.lastName,
          company: address.company ?? '',
          line1: address.line1,
          line2: address.line2 ?? '',
          city: address.city,
          province: address.province ?? '',
          postalCode: address.postalCode,
          countryCode: address.countryCode,
          phone: address.phone ?? '',
        );

  CustomerAddressControllers._({
    String firstName = '',
    String lastName = '',
    String company = '',
    String line1 = '',
    String line2 = '',
    String city = '',
    String province = '',
    String postalCode = '',
    String countryCode = '',
    String phone = '',
  })  : firstName = TextEditingController(text: firstName),
        lastName = TextEditingController(text: lastName),
        company = TextEditingController(text: company),
        line1 = TextEditingController(text: line1),
        line2 = TextEditingController(text: line2),
        city = TextEditingController(text: city),
        province = TextEditingController(text: province),
        postalCode = TextEditingController(text: postalCode),
        countryCode = TextEditingController(text: countryCode),
        phone = TextEditingController(text: phone);

  /// City or locality.
  final TextEditingController city;

  /// Optional company or organization.
  final TextEditingController company;

  /// Selected ISO country code.
  final TextEditingController countryCode;

  /// Recipient given name.
  final TextEditingController firstName;

  /// Recipient family name.
  final TextEditingController lastName;

  /// Primary street address.
  final TextEditingController line1;

  /// Apartment, suite, or unit.
  final TextEditingController line2;

  /// Optional courier contact number.
  final TextEditingController phone;

  /// Postal or ZIP code.
  final TextEditingController postalCode;

  /// State, province, or region.
  final TextEditingController province;

  /// Builds the explicit address mutation sent to the API.
  CustomerAddressInput input({
    required bool isDefaultShipping,
    required bool isDefaultBilling,
  }) =>
      CustomerAddressInput(
        firstName: firstName.text,
        lastName: lastName.text,
        company: company.text,
        line1: line1.text,
        line2: line2.text,
        city: city.text,
        province: province.text,
        postalCode: postalCode.text,
        countryCode: countryCode.text,
        phone: phone.text,
        isDefaultShipping: isDefaultShipping,
        isDefaultBilling: isDefaultBilling,
      );

  /// Releases every controller owned by the form.
  void dispose() {
    for (final controller in [
      firstName,
      lastName,
      company,
      line1,
      line2,
      city,
      province,
      postalCode,
      countryCode,
      phone,
    ]) {
      controller.dispose();
    }
  }
}
