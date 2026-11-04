import 'package:commerce_admin_shared/src/admin_option.dart';
import 'package:dust_dart/serde.dart';

part 'admin_update_customer.g.dart';

/// Merchant input matching Medusa's customer-edit drawer.
@Derive([ToString(), Eq(), Validate(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminUpdateCustomer with _$AdminUpdateCustomer {
  /// Creates one explicit customer profile replacement.
  const AdminUpdateCustomer({
    required this.emailValue,
    required this.companyNameValue,
    required this.firstNameValue,
    required this.lastNameValue,
    required this.phoneValue,
  });

  /// Decodes one generated Admin update request.
  factory AdminUpdateCustomer.fromJson(Map<String, Object?> json) =>
      _$AdminUpdateCustomerFromJson(json);

  /// Nullable wire value used to clear the company.
  @SerDe(rename: 'company_name', using: _UpdateCustomerTextCodec())
  @Validate(length: Length(min: 1, max: 255), message: 'Enter a company')
  final String? companyNameValue;

  /// Optional replacement company.
  Option<String> get companyName => adminOptionOf(companyNameValue);

  /// Guest email replacement, absent for registered accounts.
  @SerDe(rename: 'email', using: _UpdateCustomerEmailCodec())
  @Validate(length: Length(min: 3, max: 254), message: 'Enter a valid email')
  @Validate(email: true, message: 'Enter a valid email')
  final String? emailValue;

  /// Optional email mutation requested by the client.
  Option<String> get email => adminOptionOf(emailValue);

  /// Nullable wire value used to clear the given name.
  @SerDe(rename: 'first_name', using: _UpdateCustomerTextCodec())
  @Validate(length: Length(min: 1, max: 100), message: 'Enter a first name')
  final String? firstNameValue;

  /// Optional replacement given name.
  Option<String> get firstName => adminOptionOf(firstNameValue);

  /// Nullable wire value used to clear the family name.
  @SerDe(rename: 'last_name', using: _UpdateCustomerTextCodec())
  @Validate(length: Length(min: 1, max: 100), message: 'Enter a last name')
  final String? lastNameValue;

  /// Optional replacement family name.
  Option<String> get lastName => adminOptionOf(lastNameValue);

  /// Nullable wire value used to clear the phone number.
  @SerDe(rename: 'phone', using: _UpdateCustomerTextCodec())
  @Validate(length: Length(min: 1, max: 50), message: 'Enter a phone number')
  final String? phoneValue;

  /// Optional replacement phone number.
  Option<String> get phone => adminOptionOf(phoneValue);
}

final class _UpdateCustomerEmailCodec implements SerDeCodec<String, String> {
  const _UpdateCustomerEmailCodec();

  @override
  String deserialize(String value) => value.trim().toLowerCase();

  @override
  String serialize(String value) => value.trim().toLowerCase();
}

final class _UpdateCustomerTextCodec implements SerDeCodec<String, String> {
  const _UpdateCustomerTextCodec();

  @override
  String deserialize(String value) => value.trim();

  @override
  String serialize(String value) => value.trim();
}
