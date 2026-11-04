import 'package:commerce_admin_shared/src/admin_customer_group.dart';
import 'package:commerce_admin_shared/src/admin_option.dart';
import 'package:dust_dart/serde.dart';

part 'admin_customer_group_detail.g.dart';

/// Explicit merchant allowlist for one customer-group detail route.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminCustomerGroupDetail with _$AdminCustomerGroupDetail {
  /// Creates one immutable customer-group detail response.
  const AdminCustomerGroupDetail({
    required this.id,
    required this.name,
    required this.customers,
    required this.metadataValue,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Decodes one generated Admin API response.
  factory AdminCustomerGroupDetail.fromJson(Map<String, Object?> json) =>
      _$AdminCustomerGroupDetailFromJson(json);

  /// Database-generated creation instant.
  final DateTime createdAt;

  /// Active customer identifiers included by Medusa's detail field selection.
  final List<AdminCustomerGroupCustomer> customers;

  /// Stable opaque customer-group identifier.
  final String id;

  /// Merchant extension data when supplied.
  Option<Map<String, Object?>> get metadata => adminOptionOf(metadataValue);

  /// Nullable JSON backing for [metadata].
  @SerDe(rename: 'metadata')
  final Map<String, Object?>? metadataValue;

  /// Merchant-facing customer segment name.
  final String name;

  /// Database-generated last mutation instant.
  final DateTime updatedAt;
}

/// Medusa-compatible envelope returned by customer-group detail retrieval.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminCustomerGroupDetailResponse
    with _$AdminCustomerGroupDetailResponse {
  /// Creates one explicit customer-group detail envelope.
  const AdminCustomerGroupDetailResponse({required this.customerGroup});

  /// Decodes one generated Admin API response.
  factory AdminCustomerGroupDetailResponse.fromJson(
    Map<String, Object?> json,
  ) =>
      _$AdminCustomerGroupDetailResponseFromJson(json);

  /// Merchant-visible customer-group detail.
  final AdminCustomerGroupDetail customerGroup;
}
