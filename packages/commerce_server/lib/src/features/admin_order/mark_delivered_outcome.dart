import 'package:commerce_server/src/features/admin_order/detail_model.dart';
import 'package:commerce_server/src/features/admin_order/mark_delivered_failure.dart';

/// Transaction value keeping refusal out of nested Result types.
sealed class AdminMarkDeliveredOutcome {
  const AdminMarkDeliveredOutcome();
}

/// Delivered fulfillment and its refreshed direct-SQLx order response.
final class AdminMarkDeliveredReady extends AdminMarkDeliveredOutcome {
  /// Creates a successful delivery outcome.
  const AdminMarkDeliveredReady(this.response);

  /// Refreshed merchant order response.
  final AdminOrderDetailResponse response;
}

/// Expected refusal that produces no partial persistence.
final class AdminMarkDeliveredDenied extends AdminMarkDeliveredOutcome {
  /// Creates a denied delivery outcome.
  const AdminMarkDeliveredDenied(this.failure);

  /// Stable business reason.
  final AdminMarkDeliveredFailure failure;
}
