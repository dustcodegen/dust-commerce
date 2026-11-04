import 'package:commerce_app/commerce_app.dart';
import 'package:flutter/material.dart';

/// Text controllers kept together so address conversion is explicit.
final class CheckoutAddressControllers {
  /// Creates controllers seeded from an already-retained [draft].
  CheckoutAddressControllers(CheckoutAddressDraft draft)
      : firstName = TextEditingController(text: draft.firstName),
        lastName = TextEditingController(text: draft.lastName),
        company = TextEditingController(text: draft.company),
        line1 = TextEditingController(text: draft.line1),
        line2 = TextEditingController(text: draft.line2),
        city = TextEditingController(text: draft.city),
        province = TextEditingController(text: draft.province),
        postalCode = TextEditingController(text: draft.postalCode),
        countryCode = TextEditingController(text: draft.countryCode),
        phone = TextEditingController(text: draft.phone);

  /// City field.
  final TextEditingController city;

  /// Country selection field.
  final TextEditingController countryCode;

  /// Optional company or organization field.
  final TextEditingController company;

  /// Given-name field.
  final TextEditingController firstName;

  /// Family-name field.
  final TextEditingController lastName;

  /// Primary street field.
  final TextEditingController line1;

  /// Apartment, suite, or secondary street field.
  final TextEditingController line2;

  /// Contact telephone field.
  final TextEditingController phone;

  /// Postal-code field.
  final TextEditingController postalCode;

  /// State or province field.
  final TextEditingController province;

  /// Current form values as a durable checkout draft.
  CheckoutAddressDraft get draft => CheckoutAddressDraft(
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
      );

  /// Replaces the form with a customer-selected saved destination.
  void replace(CheckoutAddressDraft draft) {
    firstName.text = draft.firstName;
    lastName.text = draft.lastName;
    company.text = draft.company;
    line1.text = draft.line1;
    line2.text = draft.line2;
    city.text = draft.city;
    province.text = draft.province;
    postalCode.text = draft.postalCode;
    countryCode.text = draft.countryCode;
    phone.text = draft.phone;
  }

  /// Releases all text-editing resources.
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
