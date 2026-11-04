import 'package:commerce_admin_shared/src/admin_option.dart';
import 'package:dust_dart/serde.dart';

part 'admin_order_address.g.dart';

/// Postal address frozen when an order was placed.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminOrderAddress with _$AdminOrderAddress {
  /// Creates a merchant-visible address without persistence fields.
  const AdminOrderAddress({
    required this.firstName,
    required this.lastName,
    required this.companyValue,
    required this.line1,
    required this.line2Value,
    required this.city,
    required this.provinceValue,
    required this.postalCode,
    required this.countryCode,
    required this.phoneValue,
  });

  /// Decodes one generated Admin address response.
  factory AdminOrderAddress.fromJson(Map<String, Object?> json) =>
      _$AdminOrderAddressFromJson(json);

  /// Town or city captured at checkout.
  final String city;

  /// Nullable JSON backing for [company].
  @SerDe(rename: 'company')
  final String? companyValue;

  /// Lowercase ISO 3166-1 alpha-2 country code.
  final String countryCode;

  /// Recipient given name.
  final String firstName;

  /// Recipient family name.
  final String lastName;

  /// Primary street line.
  final String line1;

  /// Nullable JSON backing for [line2].
  @SerDe(rename: 'line2')
  final String? line2Value;

  /// Nullable JSON backing for [phone].
  @SerDe(rename: 'phone')
  final String? phoneValue;

  /// Postal or ZIP code.
  final String postalCode;

  /// Nullable JSON backing for [province].
  @SerDe(rename: 'province')
  final String? provinceValue;

  /// Optional company distinct from the secondary street line.
  Option<String> get company => adminOptionOf(companyValue);

  /// Optional apartment, suite, or unit.
  Option<String> get line2 => adminOptionOf(line2Value);

  /// Optional courier contact number.
  Option<String> get phone => adminOptionOf(phoneValue);

  /// Optional state, province, or region.
  Option<String> get province => adminOptionOf(provinceValue);
}
