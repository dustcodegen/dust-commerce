import 'package:dust_dart/derive.dart';

/// Customer-service sort orders accepted by the Admin inbox.
enum AdminCustomerServiceOrder {
  /// Oldest requests first.
  createdAtAsc('created_at'),

  /// Newest requests first.
  createdAtDesc('-created_at'),

  /// Least recently changed requests first.
  updatedAtAsc('updated_at'),

  /// Most recently changed requests first.
  updatedAtDesc('-updated_at');

  const AdminCustomerServiceOrder(this.parameter);

  /// Stable Admin API query value.
  final String parameter;

  /// Parses one allowlisted Admin API query value.
  static Option<AdminCustomerServiceOrder> parse(String parameter) {
    for (final order in values) {
      if (order.parameter == parameter) return Some(order);
    }
    return const None();
  }
}
