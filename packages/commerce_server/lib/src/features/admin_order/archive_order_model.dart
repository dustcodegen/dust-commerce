import 'package:dust_dart/db.dart';

part 'archive_order_model.g.dart';

/// Minimal direct SQLx projection used before archiving one order.
@Derive([FromRow()])
final class AdminArchiveOrderTarget {
  /// Creates the lifecycle decision projection.
  const AdminArchiveOrderTarget({required this.status});

  /// Current order lifecycle.
  final String status;
}
