import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin/extractor.dart';
import 'package:commerce_server/src/features/admin_order/deps.dart';
import 'package:commerce_server/src/features/admin_order/detail_model.dart';
import 'package:commerce_server/src/features/admin_order/mark_delivered_failure.dart';
import 'package:commerce_server/src/features/admin_order/mark_delivered_service.dart';
import 'package:dust_server/server.dart';

const JsonExtractable<AdminMarkFulfillmentDelivered> _deliveryBody =
    JsonExtractable(AdminMarkFulfillmentDelivered.fromJson);

/// Marks one active order fulfillment delivered.
Future<Result<AdminOrderDetailResponse, Rejection>>
    markAdminOrderFulfillmentDeliveredHandler(Request request) async {
  final authenticated =
      await const Extension<AuthenticatedAdmin>().extract(request);
  if (authenticated case Err(:final error)) return Err(error);
  final parameters = pathParametersOf(request);
  final orderId = parameters['id'];
  final fulfillmentId = parameters['fulfillment_id'];
  if (orderId == null || orderId.isEmpty) {
    return const Err(Rejection.badRequest('An order id is required'));
  }
  if (fulfillmentId == null || fulfillmentId.isEmpty) {
    return const Err(Rejection.badRequest('A fulfillment id is required'));
  }
  final decoded = await _deliveryBody.extract(request);
  if (decoded case Err(:final error)) return Err(error);
  final state = await adminOrderDeps(request);
  if (state case Err(:final error)) return Err(error);
  final deps = (state as Ok<AdminOrderDeps, Rejection>).value;
  final result = await markAdminOrderFulfillmentDelivered(
    deps,
    orderId,
    fulfillmentId,
    (decoded as Ok<AdminMarkFulfillmentDelivered, Rejection>).value,
  );
  return switch (result) {
    Ok(:final value) => Ok(value),
    Err(
      error: AdminMarkDeliveredRejected(
        failure: AdminMarkDeliveredFailure.unavailable,
      )
    ) =>
      Err(Rejection.notFound('Order fulfillment')),
    Err(
      error: AdminMarkDeliveredRejected(
        failure: AdminMarkDeliveredFailure.invalid,
      )
    ) =>
      const Err(Rejection.status(422, 'Delivery command is invalid')),
    Err(
      error: AdminMarkDeliveredRejected(
        failure: AdminMarkDeliveredFailure.notificationUnavailable,
      )
    ) =>
      const Err(Rejection.status(503, 'Delivery notification unavailable')),
    Err(error: AdminMarkDeliveredStorage()) => const Err(Rejection.internal()),
  };
}
