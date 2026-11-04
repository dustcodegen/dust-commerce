import 'package:dust_dart/db.dart';
import 'package:dust_dart/serde.dart';

part 'detail_address_response.g.dart';

/// One active customer address populated from an allowlisted SQL projection.
@Derive([Serialize(), Deserialize(), FromRow()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminCustomerAddressResponse with _$AdminCustomerAddressResponse {
  /// Creates one merchant-visible reusable destination.
  const AdminCustomerAddressResponse({
    required this.id,
    required this.addressName,
    required this.firstName,
    required this.lastName,
    required this.company,
    required this.phone,
    required this.address1,
    required this.address2,
    required this.city,
    required this.province,
    required this.postalCode,
    required this.countryCode,
    required this.isDefaultShipping,
    required this.isDefaultBilling,
  });

  /// Merchant-facing destination label when supplied.
  @Sqlx(rename: 'address_name')
  final String? addressName;

  /// Decodes one address from the aggregate SQL projection.
  factory AdminCustomerAddressResponse.fromJson(Map<String, Object?> json) =>
      _$AdminCustomerAddressResponseFromJson(json);

  /// Primary street address.
  @Sqlx(rename: 'address_1')
  @SerDe(rename: 'address_1')
  final String address1;

  /// Apartment, suite, or unit when supplied.
  @Sqlx(rename: 'address_2')
  @SerDe(rename: 'address_2')
  final String? address2;

  /// City or locality.
  final String? city;

  /// Recipient company when supplied.
  final String? company;

  /// Lowercase ISO 3166-1 alpha-2 country code.
  final String countryCode;

  /// Recipient given name.
  final String? firstName;

  /// Stable opaque address identifier.
  final String id;

  /// Whether this is the default billing destination.
  @Sqlx(tryFrom: _AdminCustomerAddressFlag())
  final bool isDefaultBilling;

  /// Whether this is the default shipping destination.
  @Sqlx(tryFrom: _AdminCustomerAddressFlag())
  final bool isDefaultShipping;

  /// Recipient family name.
  final String? lastName;

  /// Courier contact number when supplied.
  final String? phone;

  /// Postal or ZIP code.
  final String? postalCode;

  /// State, province, or region when supplied.
  final String? province;
}

final class _AdminCustomerAddressFlag implements SqlxTryFrom<bool, int> {
  const _AdminCustomerAddressFlag();

  @override
  bool decode(int value) => value == 1;
}
