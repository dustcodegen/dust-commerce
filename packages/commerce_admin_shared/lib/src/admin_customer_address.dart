import 'package:commerce_admin_shared/src/admin_option.dart';
import 'package:dust_dart/serde.dart';

part 'admin_customer_address.g.dart';

/// One explicitly allowlisted address on a merchant customer detail.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminCustomerAddress with _$AdminCustomerAddress {
  /// Creates an immutable merchant-facing customer address.
  const AdminCustomerAddress({
    required this.id,
    required this.addressNameValue,
    required this.firstNameValue,
    required this.lastNameValue,
    required this.line1,
    required this.cityValue,
    required this.postalCodeValue,
    required this.countryCode,
    required this.isDefaultShipping,
    required this.isDefaultBilling,
    required this.companyValue,
    required this.phoneValue,
    required this.line2Value,
    required this.provinceValue,
  });

  /// Decodes one generated Admin API response.
  factory AdminCustomerAddress.fromJson(Map<String, Object?> json) =>
      _$AdminCustomerAddressFromJson(json);

  /// Nullable wire backing for [addressName].
  @SerDe(rename: 'address_name')
  final String? addressNameValue;

  /// Merchant-facing destination label when supplied.
  Option<String> get addressName => adminOptionOf(addressNameValue);

  /// Primary street address.
  @SerDe(rename: 'address_1')
  final String line1;

  /// Nullable JSON backing for [line2].
  @SerDe(rename: 'address_2')
  final String? line2Value;

  /// Apartment, suite, or unit when supplied.
  Option<String> get line2 => adminOptionOf(line2Value);

  /// Nullable JSON backing for [city].
  @SerDe(rename: 'city')
  final String? cityValue;

  /// City or locality when supplied.
  Option<String> get city => adminOptionOf(cityValue);

  /// Nullable JSON backing for [company].
  @SerDe(rename: 'company')
  final String? companyValue;

  /// Recipient company when supplied.
  Option<String> get company => adminOptionOf(companyValue);

  /// Lowercase ISO 3166-1 alpha-2 country code.
  final String countryCode;

  /// Nullable JSON backing for [firstName].
  @SerDe(rename: 'first_name')
  final String? firstNameValue;

  /// Recipient given name when supplied.
  Option<String> get firstName => adminOptionOf(firstNameValue);

  /// Stable opaque address identifier.
  final String id;

  /// Whether this is the default billing destination.
  final bool isDefaultBilling;

  /// Whether this is the default shipping destination.
  final bool isDefaultShipping;

  /// Nullable JSON backing for [lastName].
  @SerDe(rename: 'last_name')
  final String? lastNameValue;

  /// Recipient family name when supplied.
  Option<String> get lastName => adminOptionOf(lastNameValue);

  /// Nullable JSON backing for [phone].
  @SerDe(rename: 'phone')
  final String? phoneValue;

  /// Courier contact number when supplied.
  Option<String> get phone => adminOptionOf(phoneValue);

  /// Nullable JSON backing for [postalCode].
  @SerDe(rename: 'postal_code')
  final String? postalCodeValue;

  /// Postal or ZIP code when supplied.
  Option<String> get postalCode => adminOptionOf(postalCodeValue);

  /// Nullable JSON backing for [province].
  @SerDe(rename: 'province')
  final String? provinceValue;

  /// State, province, or region when supplied.
  Option<String> get province => adminOptionOf(provinceValue);
}
