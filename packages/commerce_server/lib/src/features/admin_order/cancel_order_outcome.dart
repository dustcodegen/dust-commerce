import 'package:commerce_server/src/features/admin_order/cancel_order_failure.dart';
import 'package:commerce_server/src/features/admin_order/detail_model.dart';

/// Transaction value keeping refusal out of nested Result types.
sealed class AdminCancelOrderOutcome {
  const AdminCancelOrderOutcome();
}

/// Canceled order and its refreshed direct-SQLx response.
final class AdminCancelOrderReady extends AdminCancelOrderOutcome {
  /// Creates a successful cancellation outcome.
  const AdminCancelOrderReady(this.response);

  /// Refreshed merchant order response.
  final AdminOrderDetailResponse response;
}

/// Expected refusal that produces no partial persistence.
final class AdminCancelOrderDenied extends AdminCancelOrderOutcome {
  /// Creates a denied cancellation outcome.
  const AdminCancelOrderDenied(this.failure);

  /// Stable business reason.
  final AdminCancelOrderFailure failure;
}
