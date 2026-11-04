import 'package:dust_dart/db.dart';

part 'mark_delivered_model.g.dart';

/// Lifecycle facts read directly for one delivery transition.
@Derive([FromRow()])
final class AdminDeliveryTarget {
  /// Creates the direct SQLx lifecycle projection.
  const AdminDeliveryTarget({required this.canceled, required this.delivered});

  /// Whether the fulfillment has already been canceled.
  final bool canceled;

  /// Whether the fulfillment has already been delivered.
  final bool delivered;
}
