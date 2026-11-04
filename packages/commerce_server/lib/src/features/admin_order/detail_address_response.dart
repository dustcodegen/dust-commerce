import 'package:dust_dart/serde.dart';

part 'detail_address_response.g.dart';

/// Merchant-safe order address decoded from the SQL detail projection.
@Derive([Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminOrderAddressResponse with _$AdminOrderAddressResponse {
  /// Creates one frozen address without persistence fields.
  const AdminOrderAddressResponse({
    required this.firstName,
    required this.lastName,
    required this.company,
    required this.line1,
    required this.line2,
    required this.city,
    required this.province,
    required this.postalCode,
    required this.countryCode,
    required this.phone,
  });

  /// Decodes the JSON object selected by SQLite.
  factory AdminOrderAddressResponse.fromJson(Map<String, Object?> json) =>
      _$AdminOrderAddressResponseFromJson(json);

  /// Town or city captured at checkout.
  final String city;

  /// Optional organization name.
  final String? company;

  /// Lowercase ISO 3166-1 alpha-2 country code.
  final String countryCode;

  /// Recipient given name.
  final String firstName;

  /// Recipient family name.
  final String lastName;

  /// Primary street line.
  final String line1;

  /// Optional apartment, suite, or unit.
  final String? line2;

  /// Optional courier contact number.
  final String? phone;

  /// Postal or ZIP code.
  final String postalCode;

  /// Optional state, province, or region.
  final String? province;
}
