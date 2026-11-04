import 'package:dust_dart/db.dart';

part 'cancel_fulfillment_model.g.dart';

/// Lifecycle and provider facts read directly for one cancellation.
@Derive([FromRow()])
final class AdminCancelFulfillmentTarget {
  /// Creates the direct SQLx cancellation projection.
  const AdminCancelFulfillmentTarget({
    required this.providerId,
    required this.canceled,
    required this.shipped,
    required this.delivered,
  });

  /// Whether the fulfillment has already been canceled.
  final bool canceled;

  /// Whether the fulfillment has already been delivered.
  final bool delivered;

  /// Provider whose external state would need cancellation.
  @Sqlx(rename: 'provider_id')
  final String providerId;

  /// Whether the fulfillment has already been shipped.
  final bool shipped;
}
