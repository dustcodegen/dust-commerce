import 'package:commerce_admin_shared/src/admin_option.dart';
import 'package:dust_dart/serde.dart';

part 'admin_create_customer.g.dart';

/// Merchant input matching Medusa's focused customer-create form.
@Derive([ToString(), Eq(), Validate(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminCreateCustomer with _$AdminCreateCustomer {
  /// Creates a non-authenticating customer profile.
  const AdminCreateCustomer({
    required this.email,
    required this.companyNameValue,
    required this.firstNameValue,
    required this.lastNameValue,
    required this.phoneValue,
  });

  /// Decodes one generated Admin request.
  factory AdminCreateCustomer.fromJson(Map<String, Object?> json) =>
      _$AdminCreateCustomerFromJson(json);

  /// Nullable wire backing for [companyName].
  @SerDe(rename: 'company_name', using: _CustomerTextCodec())
  @Validate(length: Length(min: 1, max: 255), message: 'Enter a company')
  final String? companyNameValue;

  /// Optional merchant-entered company.
  Option<String> get companyName => adminOptionOf(companyNameValue);

  /// Required customer email, normalized at the SerDe boundary.
  @SerDe(using: _CustomerEmailCodec())
  @Validate(length: Length(min: 3, max: 254), message: 'Enter a valid email')
  @Validate(email: true, message: 'Enter a valid email')
  final String email;

  /// Nullable wire backing for [firstName].
  @SerDe(rename: 'first_name', using: _CustomerTextCodec())
  @Validate(length: Length(min: 1, max: 100), message: 'Enter a first name')
  final String? firstNameValue;

  /// Optional customer given name.
  Option<String> get firstName => adminOptionOf(firstNameValue);

  /// Nullable wire backing for [lastName].
  @SerDe(rename: 'last_name', using: _CustomerTextCodec())
  @Validate(length: Length(min: 1, max: 100), message: 'Enter a last name')
  final String? lastNameValue;

  /// Optional customer family name.
  Option<String> get lastName => adminOptionOf(lastNameValue);

  /// Nullable wire backing for [phone].
  @SerDe(rename: 'phone', using: _CustomerTextCodec())
  @Validate(length: Length(min: 1, max: 50), message: 'Enter a phone number')
  final String? phoneValue;

  /// Optional customer phone number.
  Option<String> get phone => adminOptionOf(phoneValue);
}

final class _CustomerEmailCodec implements SerDeCodec<String, String> {
  const _CustomerEmailCodec();

  @override
  String deserialize(String value) => value.trim().toLowerCase();

  @override
  String serialize(String value) => value.trim().toLowerCase();
}

final class _CustomerTextCodec implements SerDeCodec<String, String> {
  const _CustomerTextCodec();

  @override
  String deserialize(String value) => value.trim();

  @override
  String serialize(String value) => value.trim();
}
