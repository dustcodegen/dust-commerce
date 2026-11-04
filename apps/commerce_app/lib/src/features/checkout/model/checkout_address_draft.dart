import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_dart/derive.dart';

part 'checkout_address_draft.g.dart';

/// Editable address values retained while the customer moves between steps.
@Derive([ToString(), Eq(), CopyWith()])
final class CheckoutAddressDraft with _$CheckoutAddressDraft {
  /// Creates an address draft without treating empty form values as valid.
  const CheckoutAddressDraft({
    this.firstName = '',
    this.lastName = '',
    this.line1 = '',
    this.line2 = '',
    this.city = '',
    this.province = '',
    this.postalCode = '',
    this.countryCode = '',
    this.phone = '',
    this.company = '',
  });

  /// Creates editable checkout values from a customer-owned saved address.
  factory CheckoutAddressDraft.fromSavedAddress(CustomerAddressView address) =>
      CheckoutAddressDraft(
        firstName: address.firstName,
        lastName: address.lastName,
        company: address.company ?? '',
        line1: address.line1,
        line2: address.line2 ?? '',
        city: address.city,
        province: address.province ?? '',
        postalCode: address.postalCode,
        countryCode: address.countryCode.toLowerCase(),
        phone: address.phone ?? '',
      );

  /// Creates editable checkout values from a cart-owned destination.
  factory CheckoutAddressDraft.fromAddress(Address address) =>
      CheckoutAddressDraft(
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

  /// Town or city field value.
  final String city;

  /// Optional company or organization field value.
  final String company;

  /// Selected two-letter country code.
  final String countryCode;

  /// Given-name field value.
  final String firstName;

  /// Family-name field value.
  final String lastName;

  /// Primary street-address field value.
  final String line1;

  /// Optional apartment, suite, or secondary street field value.
  final String line2;

  /// Optional delivery contact number.
  final String phone;

  /// Postal or ZIP code field value.
  final String postalCode;

  /// Optional state or province field value.
  final String province;

  /// Converts trimmed form values into the validated request boundary.
  AddressInput toInput() => AddressInput(
        firstName: firstName.trim(),
        lastName: lastName.trim(),
        company: _optional(company),
        line1: line1.trim(),
        line2: _optional(line2),
        city: city.trim(),
        province: _optional(province),
        postalCode: postalCode.trim(),
        countryCode: countryCode.trim().toLowerCase(),
        phone: _optional(phone),
      );

  /// Whether the editable form still represents this saved address.
  bool matchesSavedAddress(CustomerAddressView address) =>
      this == CheckoutAddressDraft.fromSavedAddress(address);

  static String? _optional(String value) {
    final normalized = value.trim();
    return normalized.isEmpty ? null : normalized;
  }
}
