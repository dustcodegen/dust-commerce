import 'package:commerce_admin_shared/src/admin_option.dart';
import 'package:dust_dart/serde.dart';

part 'admin_customer.g.dart';

/// One explicitly allowlisted row in the merchant customer table.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminCustomer with _$AdminCustomer {
  /// Creates an immutable merchant-facing customer summary.
  const AdminCustomer({
    required this.id,
    required this.emailValue,
    required this.firstNameValue,
    required this.lastNameValue,
    required this.hasAccount,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Decodes one generated Admin API response.
  factory AdminCustomer.fromJson(Map<String, Object?> json) =>
      _$AdminCustomerFromJson(json);

  /// Database-generated first-seen instant.
  final DateTime createdAt;

  /// Nullable JSON backing for [email].
  @SerDe(rename: 'email')
  final String? emailValue;

  /// Merchant-visible contact email when one exists.
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

  /// Database-generated last mutation instant.
  final DateTime updatedAt;
}

/// One bounded page returned by the merchant customer API.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminCustomerList with _$AdminCustomerList {
  /// Creates one customer page with server-owned paging metadata.
  const AdminCustomerList({
    required this.customers,
    required this.count,
    required this.limit,
    required this.offset,
  });

  /// Decodes one generated Admin API response.
  factory AdminCustomerList.fromJson(Map<String, Object?> json) =>
      _$AdminCustomerListFromJson(json);

  /// Total active customers matching the query.
  final int count;

  /// Explicit merchant-safe customer rows.
  final List<AdminCustomer> customers;

  /// Maximum requested page size.
  final int limit;

  /// Number of matching rows skipped.
  final int offset;
}
