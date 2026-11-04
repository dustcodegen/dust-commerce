import 'dart:convert';

import 'package:dust_dart/db.dart';
import 'package:dust_dart/serde.dart';

part 'list_response.g.dart';

/// One intentionally minimal customer reference inside a group row.
@Derive([Serialize(), Deserialize()])
final class AdminCustomerGroupCustomerResponse
    with _$AdminCustomerGroupCustomerResponse {
  /// Creates one group membership reference.
  const AdminCustomerGroupCustomerResponse({required this.id});

  /// Decodes one customer id from SQLite's nested JSON projection.
  factory AdminCustomerGroupCustomerResponse.fromJson(
    Map<String, Object?> json,
  ) =>
      _$AdminCustomerGroupCustomerResponseFromJson(json);

  /// Stable opaque customer identifier.
  final String id;
}

/// One customer-group table response populated directly from SQLx.
@Derive([Serialize(), FromRow()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminCustomerGroupResponse with _$AdminCustomerGroupResponse {
  /// Creates an explicitly allowlisted merchant customer-group row.
  const AdminCustomerGroupResponse({
    required this.id,
    required this.name,
    required this.customers,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Database-generated creation instant decoded from PostgreSQL TIMESTAMPTZ.
  @Sqlx(rename: 'created_at', tryFrom: _AdminCustomerGroupDateTime())
  final DateTime createdAt;

  /// Active customer ids selected by the ordered nested projection.
  @SerDe(rename: 'customers')
  @Sqlx(rename: 'customers_json', tryFrom: _AdminCustomerGroupCustomers())
  final List<AdminCustomerGroupCustomerResponse> customers;

  /// Stable opaque group identifier.
  final String id;

  /// Merchant-facing segment name.
  final String name;

  /// Database-generated last mutation instant decoded from PostgreSQL TIMESTAMPTZ.
  @Sqlx(rename: 'updated_at', tryFrom: _AdminCustomerGroupDateTime())
  final DateTime updatedAt;
}

/// Customer-group rows plus bounded-list metadata.
@Derive([Serialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminCustomerGroupListResponse
    with _$AdminCustomerGroupListResponse {
  /// Creates one merchant customer-group page.
  const AdminCustomerGroupListResponse({
    required this.customerGroups,
    required this.count,
    required this.limit,
    required this.offset,
  });

  /// Total active rows matching the query.
  final int count;

  /// Explicit direct SQLx group summaries.
  final List<AdminCustomerGroupResponse> customerGroups;

  /// Maximum requested page size.
  final int limit;

  /// Number of matching rows skipped.
  final int offset;
}

final class _AdminCustomerGroupDateTime
    implements SqlxTryFrom<DateTime, DateTime> {
  const _AdminCustomerGroupDateTime();

  @override
  DateTime decode(DateTime value) => value.toUtc();
}

final class _AdminCustomerGroupCustomers
    implements SqlxTryFrom<List<AdminCustomerGroupCustomerResponse>, String> {
  const _AdminCustomerGroupCustomers();

  @override
  List<AdminCustomerGroupCustomerResponse> decode(String value) {
    final decoded = jsonDecode(value);
    if (decoded is! List<Object?>) {
      throw const FormatException('Customer group members must be a list');
    }
    return decoded.map((item) {
      if (item is! Map<String, Object?>) {
        throw const FormatException('Customer group member must be an object');
      }
      return AdminCustomerGroupCustomerResponse.fromJson(item);
    }).toList(growable: false);
  }
}
