import 'package:dust_dart/serde.dart';

part 'admin_customer_group.g.dart';

/// One customer identifier returned in a group-list row.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
final class AdminCustomerGroupCustomer with _$AdminCustomerGroupCustomer {
  /// Creates an intentionally minimal group membership reference.
  const AdminCustomerGroupCustomer({required this.id});

  /// Decodes one generated Admin API response.
  factory AdminCustomerGroupCustomer.fromJson(Map<String, Object?> json) =>
      _$AdminCustomerGroupCustomerFromJson(json);

  /// Stable opaque customer identifier.
  final String id;
}

/// One explicitly allowlisted row in the merchant customer-group table.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminCustomerGroup with _$AdminCustomerGroup {
  /// Creates one merchant-facing customer-group summary.
  const AdminCustomerGroup({
    required this.id,
    required this.name,
    required this.customers,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Decodes one generated Admin API response.
  factory AdminCustomerGroup.fromJson(Map<String, Object?> json) =>
      _$AdminCustomerGroupFromJson(json);

  /// Database-generated creation instant.
  final DateTime createdAt;

  /// Customer identifiers selected by the list query.
  final List<AdminCustomerGroupCustomer> customers;

  /// Stable opaque group identifier.
  final String id;

  /// Merchant-facing segment name.
  final String name;

  /// Database-generated last mutation instant.
  final DateTime updatedAt;
}

/// Medusa-compatible envelope returned after customer-group creation.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminCustomerGroupCreateResponse
    with _$AdminCustomerGroupCreateResponse {
  /// Creates one explicit group response envelope.
  const AdminCustomerGroupCreateResponse({required this.customerGroup});

  /// Decodes one generated Admin API response.
  factory AdminCustomerGroupCreateResponse.fromJson(
    Map<String, Object?> json,
  ) =>
      _$AdminCustomerGroupCreateResponseFromJson(json);

  /// Newly created allowlisted customer-group row.
  final AdminCustomerGroup customerGroup;
}

/// One bounded page returned by the merchant customer-group API.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminCustomerGroupList with _$AdminCustomerGroupList {
  /// Creates one group page with server-owned paging metadata.
  const AdminCustomerGroupList({
    required this.customerGroups,
    required this.count,
    required this.limit,
    required this.offset,
  });

  /// Decodes one generated Admin API response.
  factory AdminCustomerGroupList.fromJson(Map<String, Object?> json) =>
      _$AdminCustomerGroupListFromJson(json);

  /// Total active groups matching the query.
  final int count;

  /// Explicit merchant-safe group rows.
  final List<AdminCustomerGroup> customerGroups;

  /// Maximum requested page size.
  final int limit;

  /// Number of matching rows skipped.
  final int offset;
}
