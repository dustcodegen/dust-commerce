import 'package:dust_dart/serde.dart';

part 'address.g.dart';

/// A postal address, as a shipping or billing destination.
///
/// Kept deliberately loose: address formats differ enough between countries
/// that a schema strict enough for one is wrong for another. Only the country
/// code is checked, because that is the field the tax and shipping rules read.
@Derive([ToString(), Eq(), CopyWith(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
class Address with _$Address {
  /// Creates an [Address] from already-normalised values.
  const Address({
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
  });

  /// Creates an [Address], normalising the country code.
  factory Address.of({
    required String firstName,
    required String lastName,
    required String line1,
    required String city,
    required String postalCode,
    required String countryCode,
    String? company,
    String? line2,
    String? province,
    String? phone,
  }) {
    if (!_alpha2.hasMatch(countryCode)) {
      throw ArgumentError.value(
        countryCode,
        'countryCode',
        'expected a two-letter ISO 3166-1 code',
      );
    }
    return Address(
      firstName: firstName,
      lastName: lastName,
      company: company,
      line1: line1,
      line2: line2,
      city: city,
      province: province,
      postalCode: postalCode,
      countryCode: countryCode.toLowerCase(),
      phone: phone,
    );
  }

  /// Creates an [Address] from JSON.
  factory Address.fromJson(Map<String, Object?> json) =>
      _$AddressFromJson(json);

  /// Town or city.
  final String city;

  /// Optional company or organization captured with the destination.
  final String? company;

  /// ISO 3166-1 alpha-2 country code, lower case.
  final String countryCode;

  /// Given name.
  final String firstName;

  /// Family name.
  final String lastName;

  /// Street address.
  final String line1;

  /// Apartment, suite, or similar.
  final String? line2;

  /// Contact number for the courier.
  final String? phone;

  /// Postal or ZIP code.
  final String postalCode;

  /// State, province, or region.
  final String? province;

  /// The recipient's full name.
  String get fullName => '$firstName $lastName';

  static final RegExp _alpha2 = RegExp(r'^[A-Za-z]{2}$');
}
