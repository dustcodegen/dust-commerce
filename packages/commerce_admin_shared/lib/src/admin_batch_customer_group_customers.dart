import 'package:dust_dart/serde.dart';

part 'admin_batch_customer_group_customers.g.dart';

/// Medusa-compatible add/remove batch for one customer group's members.
@Derive([ToString(), Eq(), Validate(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminBatchCustomerGroupCustomers
    with _$AdminBatchCustomerGroupCustomers {
  /// Creates one idempotent customer membership batch.
  const AdminBatchCustomerGroupCustomers({
    this.add = const [],
    this.remove = const [],
  });

  /// Decodes the generated Admin request body.
  factory AdminBatchCustomerGroupCustomers.fromJson(
    Map<String, Object?> json,
  ) =>
      _$AdminBatchCustomerGroupCustomersFromJson(json);

  /// Active customer ids to add to the group.
  @SerDe(defaultValue: <String>[])
  final List<String> add;

  /// Active customer ids to remove from the group.
  @SerDe(defaultValue: <String>[])
  final List<String> remove;
}
