import 'package:commerce_server/src/features/admin_order/create_fulfillment_failure.dart';
import 'package:commerce_server/src/features/admin_order/detail_model.dart';

/// Transaction value keeping refusal out of nested Result types.
sealed class AdminCreateFulfillmentOutcome {
  const AdminCreateFulfillmentOutcome();
}

/// Persisted fulfillment and its refreshed direct-SQLx order response.
final class AdminCreateFulfillmentReady extends AdminCreateFulfillmentOutcome {
  /// Creates a successful fulfillment outcome.
  const AdminCreateFulfillmentReady(this.response);

  /// Refreshed merchant order response.
  final AdminOrderDetailResponse response;
}

/// Expected refusal that produces no partial persistence.
final class AdminCreateFulfillmentDenied extends AdminCreateFulfillmentOutcome {
  /// Creates a denied fulfillment outcome.
  const AdminCreateFulfillmentDenied(this.failure);

  /// Stable business reason.
  final AdminCreateFulfillmentFailure failure;
}
