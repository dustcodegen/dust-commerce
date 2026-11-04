import 'package:dust_dart/derive.dart';

part 'admin_update_customer_address.g.dart';

/// Partial Medusa-compatible update for one customer-owned address.
@Derive([ToString(), Eq()])
final class AdminUpdateCustomerAddress with _$AdminUpdateCustomerAddress {
  /// Creates a patch where [None] leaves a field unchanged.
  const AdminUpdateCustomerAddress({
    this.addressName = const None(),
    this.firstName = const None(),
    this.lastName = const None(),
    this.company = const None(),
    this.phone = const None(),
    this.line1 = const None(),
    this.line2 = const None(),
    this.city = const None(),
    this.countryCode = const None(),
    this.province = const None(),
    this.postalCode = const None(),
    this.isDefaultShipping = const None(),
    this.isDefaultBilling = const None(),
  });

  /// Decodes presence separately from an explicit JSON `null` clear.
  factory AdminUpdateCustomerAddress.fromJson(Map<String, Object?> json) {
    if (json.isEmpty || json.keys.any((key) => !jsonFields.contains(key))) {
      throw const FormatException('Provide recognized address changes');
    }
    final update = AdminUpdateCustomerAddress(
      addressName: _textPatch(json, 'address_name', 255),
      firstName: _textPatch(json, 'first_name', 100),
      lastName: _textPatch(json, 'last_name', 100),
      company: _textPatch(json, 'company', 255),
      phone: _textPatch(json, 'phone', 50),
      line1: _textPatch(json, 'address_1', 255),
      line2: _textPatch(json, 'address_2', 255),
      city: _textPatch(json, 'city', 100),
      countryCode: _countryPatch(json),
      province: _textPatch(json, 'province', 100),
      postalCode: _textPatch(json, 'postal_code', 32),
      isDefaultShipping: _boolPatch(json, 'is_default_shipping'),
      isDefaultBilling: _boolPatch(json, 'is_default_billing'),
    );
    if (update.line1 case Some(value: null)) {
      throw const FormatException('Address cannot be cleared');
    }
    if (update.countryCode case Some(value: null)) {
      throw const FormatException('Country cannot be cleared');
    }
    return update;
  }

  /// Exact keys supported by the public Admin boundary.
  static const jsonFields = <String>{
    'address_name',
    'first_name',
    'last_name',
    'company',
    'phone',
    'address_1',
    'address_2',
    'city',
    'country_code',
    'province',
    'postal_code',
    'is_default_shipping',
    'is_default_billing',
  };

  /// Merchant-facing label patch; `Some(null)` clears it.
  final Option<String?> addressName;

  /// City patch; `Some(null)` clears it.
  final Option<String?> city;

  /// Company patch; `Some(null)` clears it.
  final Option<String?> company;

  /// Lowercase ISO country patch. A present value cannot be null.
  final Option<String?> countryCode;

  /// Recipient given-name patch; `Some(null)` clears it.
  final Option<String?> firstName;

  /// Default-billing flag patch.
  final Option<bool> isDefaultBilling;

  /// Default-shipping flag patch.
  final Option<bool> isDefaultShipping;

  /// Recipient family-name patch; `Some(null)` clears it.
  final Option<String?> lastName;

  /// Primary street patch. A present value cannot be null.
  final Option<String?> line1;

  /// Secondary street patch; `Some(null)` clears it.
  final Option<String?> line2;

  /// Phone patch; `Some(null)` clears it.
  final Option<String?> phone;

  /// Postal-code patch; `Some(null)` clears it.
  final Option<String?> postalCode;

  /// Province patch; `Some(null)` clears it.
  final Option<String?> province;

  /// Serializes only present fields and retains explicit JSON nulls.
  Map<String, Object?> toJson() {
    final json = <String, Object?>{};
    _put(json, 'address_name', addressName);
    _put(json, 'first_name', firstName);
    _put(json, 'last_name', lastName);
    _put(json, 'company', company);
    _put(json, 'phone', phone);
    _put(json, 'address_1', line1);
    _put(json, 'address_2', line2);
    _put(json, 'city', city);
    _put(json, 'country_code', countryCode);
    _put(json, 'province', province);
    _put(json, 'postal_code', postalCode);
    _put(json, 'is_default_shipping', isDefaultShipping);
    _put(json, 'is_default_billing', isDefaultBilling);
    return json;
  }
}

Option<String?> _textPatch(
  Map<String, Object?> json,
  String key,
  int maxLength,
) {
  if (!json.containsKey(key)) return const None();
  final value = json[key];
  if (value == null) return const Some<String?>(null);
  if (value is! String) throw FormatException('$key must be text or null');
  final normalized = value.trim();
  if (normalized.length > maxLength) {
    throw FormatException('$key exceeds $maxLength characters');
  }
  return Some(normalized.isEmpty ? null : normalized);
}

Option<String?> _countryPatch(Map<String, Object?> json) {
  final patch = _textPatch(json, 'country_code', 2);
  return switch (patch) {
    Some(:final value) when value != null && value.length == 2 =>
      Some(value.toLowerCase()),
    Some(:final value) when value != null =>
      throw const FormatException('country_code must contain two letters'),
    _ => patch,
  };
}

Option<bool> _boolPatch(Map<String, Object?> json, String key) {
  if (!json.containsKey(key)) return const None();
  final value = json[key];
  if (value is! bool) throw FormatException('$key must be a boolean');
  return Some(value);
}

void _put<T>(Map<String, Object?> json, String key, Option<T> patch) {
  if (patch case Some(:final value)) json[key] = value;
}
