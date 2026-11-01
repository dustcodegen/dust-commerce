import 'package:dust_dart/db.dart';
import 'package:dust_dart/serde.dart';

part 'model.g.dart';

/// One customer-table response populated directly from its SQL projection.
@Derive([Serialize(), FromRow()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminCustomerResponse with _$AdminCustomerResponse {
  /// Creates an explicitly allowlisted merchant customer row.
  const AdminCustomerResponse({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.hasAccount,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Database-generated first-seen instant decoded from PostgreSQL TIMESTAMPTZ.
  @Sqlx(rename: 'created_at', tryFrom: _AdminCustomerUtcDateTime())
  final DateTime createdAt;

  /// Contact email when the profile supplied one.
  final String? email;

  /// Customer given name when supplied.
  @Sqlx(rename: 'first_name')
  final String? firstName;

  /// Whether the profile owns sign-in credentials.
  @Sqlx(rename: 'has_account', tryFrom: _AdminCustomerAccountFlag())
  final bool hasAccount;

  /// Stable opaque customer identifier.
  final String id;

  /// Customer family name when supplied.
  @Sqlx(rename: 'last_name')
  final String? lastName;

  /// Database-generated last mutation instant decoded from PostgreSQL TIMESTAMPTZ.
  @Sqlx(rename: 'updated_at', tryFrom: _AdminCustomerUtcDateTime())
  final DateTime updatedAt;
}

/// Customer rows plus bounded-list metadata.
@Derive([Serialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminCustomerListResponse with _$AdminCustomerListResponse {
  /// Creates one merchant customer page.
  const AdminCustomerListResponse({
    required this.customers,
    required this.count,
    required this.limit,
    required this.offset,
  });

  /// Total active rows matching the query.
  final int count;

  /// Explicit direct SQLx customer summaries.
  final List<AdminCustomerResponse> customers;

  /// Maximum requested page size.
  final int limit;

  /// Number of matching rows skipped.
  final int offset;
}

final class _AdminCustomerUtcDateTime implements SqlxTryFrom<DateTime, String> {
  const _AdminCustomerUtcDateTime();

  @override
  DateTime decode(String value) => DateTime.parse(value).toUtc();
}

final class _AdminCustomerAccountFlag implements SqlxTryFrom<bool, int> {
  const _AdminCustomerAccountFlag();

  @override
  bool decode(int value) => value == 1;
}
