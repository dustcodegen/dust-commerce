import 'package:dust_dart/serde.dart';

part 'admin_create_customer_address.g.dart';

/// Merchant input matching Medusa's focused customer-address form and API.
@Derive([ToString(), Eq(), Validate(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminCreateCustomerAddress with _$AdminCreateCustomerAddress {
  /// Creates one explicitly allowlisted reusable destination.
  const AdminCreateCustomerAddress({
    required this.addressName,
    required this.line1,
    required this.countryCode,
    required this.companyValue,
    required this.firstNameValue,
    required this.lastNameValue,
    required this.line2Value,
    required this.cityValue,
    required this.provinceValue,
    required this.postalCodeValue,
    required this.phoneValue,
    this.isDefaultShipping = false,
    this.isDefaultBilling = false,
  });

  /// Decodes and normalizes one generated Admin request.
  factory AdminCreateCustomerAddress.fromJson(Map<String, Object?> json) =>
      _$AdminCreateCustomerAddressFromJson(json);

  /// Merchant-facing label used to identify the destination.
  @SerDe(rename: 'address_name', using: _AdminAddressTextCodec())
  @Validate(length: Length(min: 1, max: 255), message: 'Enter an address name')
  final String addressName;

  /// Primary street address.
  @SerDe(rename: 'address_1', using: _AdminAddressTextCodec())
  @Validate(length: Length(min: 1, max: 255), message: 'Enter an address')
  final String line1;

  /// Lowercase ISO 3166-1 alpha-2 country code.
  @SerDe(using: _AdminAddressCountryCodec())
  @Validate(length: Length(min: 2, max: 2), message: 'Choose a country')
  final String countryCode;

  /// Nullable wire backing for [company].
  @SerDe(rename: 'company', using: _AdminAddressOptionalCodec())
  @Validate(length: Length(max: 255))
  final String? companyValue;

  /// Recipient company when supplied.
  Option<String> get company => _adminAddressOption(companyValue);

  /// Nullable wire backing for [firstName].
  @SerDe(rename: 'first_name', using: _AdminAddressOptionalCodec())
  @Validate(length: Length(max: 100))
  final String? firstNameValue;

  /// Recipient given name when supplied.
  Option<String> get firstName => _adminAddressOption(firstNameValue);

  /// Nullable wire backing for [lastName].
  @SerDe(rename: 'last_name', using: _AdminAddressOptionalCodec())
  @Validate(length: Length(max: 100))
  final String? lastNameValue;

  /// Recipient family name when supplied.
  Option<String> get lastName => _adminAddressOption(lastNameValue);

  /// Nullable wire backing for [line2].
  @SerDe(rename: 'address_2', using: _AdminAddressOptionalCodec())
  @Validate(length: Length(max: 255))
  final String? line2Value;

  /// Apartment, suite, or unit when supplied.
  Option<String> get line2 => _adminAddressOption(line2Value);

  /// Nullable wire backing for [city].
  @SerDe(rename: 'city', using: _AdminAddressOptionalCodec())
  @Validate(length: Length(max: 100))
  final String? cityValue;

  /// City or locality when supplied.
  Option<String> get city => _adminAddressOption(cityValue);

  /// Nullable wire backing for [province].
  @SerDe(rename: 'province', using: _AdminAddressOptionalCodec())
  @Validate(length: Length(max: 100))
  final String? provinceValue;

  /// State, province, or region when supplied.
  Option<String> get province => _adminAddressOption(provinceValue);

  /// Nullable wire backing for [postalCode].
  @SerDe(rename: 'postal_code', using: _AdminAddressOptionalCodec())
  @Validate(length: Length(max: 32))
  final String? postalCodeValue;

  /// Postal or ZIP code when supplied.
  Option<String> get postalCode => _adminAddressOption(postalCodeValue);

  /// Nullable wire backing for [phone].
  @SerDe(rename: 'phone', using: _AdminAddressOptionalCodec())
  @Validate(length: Length(max: 50))
  final String? phoneValue;

  /// Courier contact number when supplied.
  Option<String> get phone => _adminAddressOption(phoneValue);

  /// Whether this becomes the default shipping destination.
  @SerDe(defaultValue: false)
  final bool isDefaultShipping;

  /// Whether this becomes the default billing destination.
  @SerDe(defaultValue: false)
  final bool isDefaultBilling;
}

final class _AdminAddressTextCodec implements SerDeCodec<String, String> {
  const _AdminAddressTextCodec();

  @override
  String deserialize(String value) => value.trim();

  @override
  String serialize(String value) => value.trim();
}

final class _AdminAddressOptionalCodec implements SerDeCodec<String, String> {
  const _AdminAddressOptionalCodec();

  @override
  String deserialize(String value) => value.trim();

  @override
  String serialize(String value) => value.trim();
}

final class _AdminAddressCountryCodec implements SerDeCodec<String, String> {
  const _AdminAddressCountryCodec();

  @override
  String deserialize(String value) => value.trim().toLowerCase();

  @override
  String serialize(String value) => value.trim().toLowerCase();
}

Option<String> _adminAddressOption(String? value) =>
    value == null || value.isEmpty ? const None() : Some(value);
