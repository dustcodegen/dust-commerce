import 'package:commerce_server/src/features/admin_order/create_shipment_failure.dart';
import 'package:commerce_server/src/features/admin_order/detail_model.dart';

/// Transaction value keeping refusal out of nested Result types.
sealed class AdminCreateShipmentOutcome {
  const AdminCreateShipmentOutcome();
}

/// Persisted shipment and its refreshed direct-SQLx order response.
final class AdminCreateShipmentReady extends AdminCreateShipmentOutcome {
  /// Creates a successful shipment outcome.
  const AdminCreateShipmentReady(this.response);

  /// Refreshed merchant order response.
  final AdminOrderDetailResponse response;
}

/// Expected refusal that produces no partial persistence.
final class AdminCreateShipmentDenied extends AdminCreateShipmentOutcome {
  /// Creates a denied shipment outcome.
  const AdminCreateShipmentDenied(this.failure);

  /// Stable business reason.
  final AdminCreateShipmentFailure failure;
}
