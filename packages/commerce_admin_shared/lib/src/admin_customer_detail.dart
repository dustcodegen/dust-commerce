import 'package:commerce_admin_shared/src/admin_customer_address.dart';
import 'package:commerce_admin_shared/src/admin_option.dart';
import 'package:dust_dart/serde.dart';

part 'admin_customer_detail.g.dart';

/// Explicit merchant allowlist for one customer detail route.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminCustomerDetail with _$AdminCustomerDetail {
  /// Creates an immutable profile with its active address book.
  const AdminCustomerDetail({
    required this.id,
    required this.emailValue,
    required this.companyNameValue,
    required this.firstNameValue,
    required this.lastNameValue,
    required this.phoneValue,
    required this.hasAccount,
    required this.createdAt,
    required this.updatedAt,
    required this.addresses,
  });

  /// Decodes one generated Admin API response.
  factory AdminCustomerDetail.fromJson(Map<String, Object?> json) =>
      _$AdminCustomerDetailFromJson(json);

  /// Active reusable destinations owned by this profile.
  final List<AdminCustomerAddress> addresses;

  /// Nullable JSON backing for [companyName].
  @SerDe(rename: 'company_name')
  final String? companyNameValue;

  /// Customer company when supplied.
  Option<String> get companyName => adminOptionOf(companyNameValue);

  /// Database-generated first-seen instant.
  final DateTime createdAt;

  /// Nullable JSON backing for [email].
  @SerDe(rename: 'email')
  final String? emailValue;

  /// Customer contact email when one exists.
  Option<String> get email => adminOptionOf(emailValue);

  /// Nullable JSON backing for [firstName].
  @SerDe(rename: 'first_name')
  final String? firstNameValue;

  /// Customer given name when supplied.
  Option<String> get firstName => adminOptionOf(firstNameValue);

  /// Whether this profile owns sign-in credentials.
  final bool hasAccount;

  /// Stable opaque customer identifier.
  final String id;

  /// Nullable JSON backing for [lastName].
  @SerDe(rename: 'last_name')
  final String? lastNameValue;

  /// Customer family name when supplied.
  Option<String> get lastName => adminOptionOf(lastNameValue);

  /// Nullable JSON backing for [phone].
  @SerDe(rename: 'phone')
  final String? phoneValue;

  /// Customer contact number when supplied.
  Option<String> get phone => adminOptionOf(phoneValue);

  /// Database-generated last mutation instant.
  final DateTime updatedAt;
}
