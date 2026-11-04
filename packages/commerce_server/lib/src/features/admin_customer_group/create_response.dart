import 'package:commerce_server/src/features/admin_customer_group/list_response.dart';
import 'package:dust_dart/serde.dart';

part 'create_response.g.dart';

/// Medusa-compatible envelope returned by customer-group creation.
@Derive([Serialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminCustomerGroupCreateResult
    with _$AdminCustomerGroupCreateResult {
  /// Creates one explicit customer-group response envelope.
  const AdminCustomerGroupCreateResult({required this.customerGroup});

  /// Direct SQLx group row without persistence-only fields.
  final AdminCustomerGroupResponse customerGroup;
}
