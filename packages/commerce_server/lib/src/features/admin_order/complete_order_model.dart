import 'package:dust_dart/db.dart';

part 'complete_order_model.g.dart';

/// Minimal direct SQLx projection used before completing one order.
@Derive([FromRow()])
final class AdminCompleteOrderTarget {
  /// Creates the lifecycle decision projection.
  const AdminCompleteOrderTarget({required this.status});

  /// Current order lifecycle.
  final String status;
}
