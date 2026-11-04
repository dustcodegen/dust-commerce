import 'package:dust_dart/derive.dart';

/// Customer-group order values exposed by Medusa's Admin table.
enum AdminCustomerGroupOrder {
  /// Group names A to Z.
  nameAsc('name'),

  /// Group names Z to A.
  nameDesc('-name'),

  /// Oldest groups first.
  createdAtAsc('created_at'),

  /// Newest groups first.
  createdAtDesc('-created_at'),

  /// Least recently updated groups first.
  updatedAtAsc('updated_at'),

  /// Most recently updated groups first.
  updatedAtDesc('-updated_at');

  const AdminCustomerGroupOrder(this.parameter);

  /// Stable Admin API query value.
  final String parameter;

  /// Parses one allowlisted Admin API query value.
  static Option<AdminCustomerGroupOrder> parse(String parameter) {
    for (final order in values) {
      if (order.parameter == parameter) return Some(order);
    }
    return const None();
  }
}
