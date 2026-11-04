import 'package:dust_dart/serde.dart';

part 'customer_address.g.dart';

/// Validated address fields accepted by customer address-book mutations.
@Derive([ToString(), Eq(), Validate(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class CustomerAddressInput with _$CustomerAddressInput {
  /// Creates a complete address mutation.
  const CustomerAddressInput({
    required this.firstName,
    required this.lastName,
    required this.line1,
    required this.city,
    required this.postalCode,
    required this.countryCode,
    this.company,
    this.line2,
    this.province,
    this.phone,
    this.isDefaultShipping = false,
    this.isDefaultBilling = false,
  });

  /// Decodes and normalizes customer-entered text at the HTTP boundary.
  factory CustomerAddressInput.fromJson(Map<String, Object?> json) =>
      _$CustomerAddressInputFromJson(_normalizedAddress(json));

  /// Primary street address.
  @SerDe(rename: 'address_1')
  @Validate(length: Length(min: 1, max: 255), message: 'Enter an address')
  final String line1;

  /// Apartment, suite, or unit.
  @SerDe(rename: 'address_2')
  @Validate(length: Length(max: 255), message: 'Use at most 255 characters')
  final String? line2;

  /// City or locality.
  @Validate(length: Length(min: 1, max: 100), message: 'Enter a city')
  final String city;

  /// Optional company or organization.
  @Validate(length: Length(max: 255), message: 'Use at most 255 characters')
  final String? company;

  /// Lowercase ISO 3166-1 alpha-2 country code.
  @Validate(length: Length(min: 2, max: 2), message: 'Choose a country')
  final String countryCode;

  /// Recipient given name.
  @Validate(length: Length(min: 1, max: 100), message: 'Enter a first name')
  final String firstName;

  /// Whether this is the default billing address.
  @SerDe(defaultValue: false)
  final bool isDefaultBilling;

  /// Whether this is the default shipping address.
  @SerDe(defaultValue: false)
  final bool isDefaultShipping;

  /// Recipient family name.
  @Validate(length: Length(min: 1, max: 100), message: 'Enter a last name')
  final String lastName;

  /// Optional courier contact number.
  @Validate(length: Length(max: 50), message: 'Use at most 50 characters')
  final String? phone;

  /// Postal or ZIP code.
  @Validate(length: Length(min: 1, max: 32), message: 'Enter a postal code')
  final String postalCode;

  /// State, province, or region.
  @Validate(length: Length(max: 100), message: 'Use at most 100 characters')
  final String? province;
}

/// One public customer address returned by the store API.
@Derive([ToString(), Eq(), CopyWith(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class CustomerAddressView with _$CustomerAddressView {
  /// Creates an explicitly allowlisted customer address.
  const CustomerAddressView({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.line1,
    required this.city,
    required this.postalCode,
    required this.countryCode,
    required this.isDefaultShipping,
    required this.isDefaultBilling,
    this.company,
    this.line2,
    this.province,
    this.phone,
  });

  /// Decodes the public response.
  factory CustomerAddressView.fromJson(Map<String, Object?> json) =>
      _$CustomerAddressViewFromJson(json);

  /// Primary street address.
  @SerDe(rename: 'address_1')
  final String line1;

  /// Apartment, suite, or unit.
  @SerDe(rename: 'address_2')
  final String? line2;

  /// City or locality.
  final String city;

  /// Optional company or organization.
  final String? company;

  /// Lowercase ISO 3166-1 alpha-2 country code.
  final String countryCode;

  /// Recipient given name.
  final String firstName;

  /// Stable address identifier.
  final String id;

  /// Whether this is the default billing destination.
  final bool isDefaultBilling;

  /// Whether this is the default shipping destination.
  final bool isDefaultShipping;

  /// Recipient family name.
  final String lastName;

  /// Optional courier contact number.
  final String? phone;

  /// Postal or ZIP code.
  final String postalCode;

  /// State, province, or region.
  final String? province;
}

/// Complete address-book listing for the authenticated customer.
@Derive([Serialize(), Deserialize()])
final class CustomerAddressListView with _$CustomerAddressListView {
  /// Creates a complete customer address-book response.
  const CustomerAddressListView({required this.addresses, required this.count});

  /// Decodes the public list response.
  factory CustomerAddressListView.fromJson(Map<String, Object?> json) =>
      _$CustomerAddressListViewFromJson(json);

  /// Active addresses owned by the authenticated customer.
  final List<CustomerAddressView> addresses;

  /// Number of returned addresses.
  final int count;
}

/// Confirms one customer address is no longer active.
@Derive([Serialize(), Deserialize()])
final class CustomerAddressDeleted with _$CustomerAddressDeleted {
  /// Creates an address-deletion confirmation.
  const CustomerAddressDeleted({required this.id, required this.success});

  /// Decodes the public deletion response.
  factory CustomerAddressDeleted.fromJson(Map<String, Object?> json) =>
      _$CustomerAddressDeletedFromJson(json);

  /// Address identifier that was removed.
  final String id;

  /// Whether the address is no longer active.
  final bool success;
}

Map<String, Object?> _normalizedAddress(Map<String, Object?> json) => {
      ...json,
      for (final key in [
        'first_name',
        'last_name',
        'address_1',
        'city',
        'postal_code',
      ])
        if (json[key] case final String value) key: value.trim(),
      for (final key in [
        'company',
        'phone',
        'address_2',
        'province',
      ])
        if (json[key] case final String value) key: _optional(value),
      if (json['country_code'] case final String value)
        'country_code': value.trim().toLowerCase(),
    };

String? _optional(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
