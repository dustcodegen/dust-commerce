import 'package:dust_dart/derive.dart';

/// Order-list values accepted by the Medusa-shaped Admin API.
enum AdminOrderOrder {
  /// Smallest display number first.
  displayIdAsc('display_id'),

  /// Largest display number first.
  displayIdDesc('-display_id'),

  /// Oldest orders first.
  createdAtAsc('created_at'),

  /// Newest orders first.
  createdAtDesc('-created_at'),

  /// Least recently updated orders first.
  updatedAtAsc('updated_at'),

  /// Most recently updated orders first.
  updatedAtDesc('-updated_at');

  const AdminOrderOrder(this.parameter);

  /// Stable query parameter value.
  final String parameter;

  /// Parses one allowlisted order value.
  static Option<AdminOrderOrder> parse(String parameter) {
    for (final order in values) {
      if (order.parameter == parameter) return Some(order);
    }
    return const None();
  }
}
