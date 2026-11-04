import 'package:commerce_server/src/features/admin_order/cancel_fulfillment_failure.dart';
import 'package:commerce_server/src/features/admin_order/detail_model.dart';

/// Transaction value keeping refusal out of nested Result types.
sealed class AdminCancelFulfillmentOutcome {
  const AdminCancelFulfillmentOutcome();
}

/// Canceled fulfillment and its refreshed direct-SQLx order response.
final class AdminCancelFulfillmentReady extends AdminCancelFulfillmentOutcome {
  /// Creates a successful cancellation outcome.
  const AdminCancelFulfillmentReady(this.response);

  /// Refreshed merchant order response.
  final AdminOrderDetailResponse response;
}

/// Expected refusal that produces no partial persistence.
final class AdminCancelFulfillmentDenied extends AdminCancelFulfillmentOutcome {
  /// Creates a denied cancellation outcome.
  const AdminCancelFulfillmentDenied(this.failure);

  /// Stable business reason.
  final AdminCancelFulfillmentFailure failure;
}
