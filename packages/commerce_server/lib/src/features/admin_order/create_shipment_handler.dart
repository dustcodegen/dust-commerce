import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin/extractor.dart';
import 'package:commerce_server/src/features/admin_order/create_shipment_failure.dart';
import 'package:commerce_server/src/features/admin_order/create_shipment_service.dart';
import 'package:commerce_server/src/features/admin_order/deps.dart';
import 'package:commerce_server/src/features/admin_order/detail_model.dart';
import 'package:dust_server/server.dart';

const JsonExtractable<AdminCreateShipment> _shipmentBody =
    JsonExtractable(AdminCreateShipment.fromJson);

/// Creates one shipment for a pending physical fulfillment.
Future<Result<AdminOrderDetailResponse, Rejection>>
    createAdminOrderShipmentHandler(Request request) async {
  final actor = await const Extension<AuthenticatedAdmin>().extract(request);
  if (actor case Err(:final error)) return Err(error);
  final parameters = pathParametersOf(request);
  final orderId = parameters['id'];
  final fulfillmentId = parameters['fulfillment_id'];
  if (orderId == null || orderId.isEmpty) {
    return const Err(Rejection.badRequest('An order id is required'));
  }
  if (fulfillmentId == null || fulfillmentId.isEmpty) {
    return const Err(Rejection.badRequest('A fulfillment id is required'));
  }
  final decoded = await _shipmentBody.extract(request);
  if (decoded case Err(:final error)) return Err(error);
  final state = await adminOrderDeps(request);
  if (state case Err(:final error)) return Err(error);
  final admin = (actor as Ok<AuthenticatedAdmin, Rejection>).value;
  final deps = (state as Ok<AdminOrderDeps, Rejection>).value;
  final result = await createAdminOrderShipment(
    deps,
    orderId,
    fulfillmentId,
    admin.user.id,
    (decoded as Ok<AdminCreateShipment, Rejection>).value,
  );
  return switch (result) {
    Ok(:final value) => Ok(value),
    Err(
      error: AdminCreateShipmentRejected(
        failure: AdminCreateShipmentFailure.unavailable,
      )
    ) =>
      Err(Rejection.notFound('Order fulfillment')),
    Err(
      error: AdminCreateShipmentRejected(
        failure: AdminCreateShipmentFailure.invalid,
      )
    ) =>
      const Err(Rejection.status(422, 'Shipment command is invalid')),
    Err(
      error: AdminCreateShipmentRejected(
        failure: AdminCreateShipmentFailure.notificationUnavailable,
      )
    ) =>
      const Err(Rejection.status(503, 'Shipment notification unavailable')),
    Err(error: AdminCreateShipmentStorage()) => const Err(Rejection.internal()),
  };
}
