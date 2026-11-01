import 'dart:convert';

import 'package:commerce_server/src/features/admin_customer_group/list_response.dart';
import 'package:dust_dart/db.dart';
import 'package:dust_dart/serde.dart';

part 'detail_response.g.dart';

/// One customer-group detail populated directly from its SQLx projection.
@Derive([Serialize(), FromRow()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminCustomerGroupDetailResponse
    with _$AdminCustomerGroupDetailResponse {
  /// Creates the explicit merchant customer-group detail.
  const AdminCustomerGroupDetailResponse({
    required this.id,
    required this.name,
    required this.customers,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Database-generated creation instant decoded from PostgreSQL TIMESTAMPTZ.
  @Sqlx(rename: 'created_at', tryFrom: _AdminCustomerGroupDetailDateTime())
  final DateTime createdAt;

  /// Active customer ids selected by the ordered nested projection.
  @SerDe(rename: 'customers')
  @Sqlx(
    rename: 'customers_json',
    tryFrom: _AdminCustomerGroupDetailCustomers(),
  )
  final List<AdminCustomerGroupCustomerResponse> customers;

  /// Stable opaque group identifier.
  final String id;

  /// Merchant extension data decoded from validated JSON storage.
  @Sqlx(
    rename: 'metadata_json',
    tryFrom: _AdminCustomerGroupDetailMetadata(),
  )
  final Map<String, Object?>? metadata;

  /// Merchant-facing segment name.
  final String name;

  /// Database-generated last mutation instant decoded from PostgreSQL TIMESTAMPTZ.
  @Sqlx(rename: 'updated_at', tryFrom: _AdminCustomerGroupDetailDateTime())
  final DateTime updatedAt;
}

/// Medusa-compatible envelope for customer-group detail retrieval.
@Derive([Serialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminCustomerGroupDetailResult
    with _$AdminCustomerGroupDetailResult {
  /// Creates one explicit group detail envelope.
  const AdminCustomerGroupDetailResult({required this.customerGroup});

  /// Direct SQLx detail without persistence-only fields.
  final AdminCustomerGroupDetailResponse customerGroup;
}

final class _AdminCustomerGroupDetailCustomers
    implements SqlxTryFrom<List<AdminCustomerGroupCustomerResponse>, String> {
  const _AdminCustomerGroupDetailCustomers();

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

final class _AdminCustomerGroupDetailMetadata
    implements SqlxTryFrom<Map<String, Object?>?, String> {
  const _AdminCustomerGroupDetailMetadata();

  @override
  Map<String, Object?>? decode(String value) {
    final decoded = jsonDecode(value);
    if (decoded == null) return null;
    if (decoded is! Map<String, Object?>) {
      throw const FormatException('Customer group metadata must be an object');
    }
    return decoded;
  }
}

final class _AdminCustomerGroupDetailDateTime
    implements SqlxTryFrom<DateTime, String> {
  const _AdminCustomerGroupDetailDateTime();

  @override
  DateTime decode(String value) => DateTime.parse(value).toUtc();
}
