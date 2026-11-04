import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin/extractor.dart';
import 'package:commerce_server/src/features/admin_order/cancel_fulfillment_failure.dart';
import 'package:commerce_server/src/features/admin_order/cancel_fulfillment_service.dart';
import 'package:commerce_server/src/features/admin_order/deps.dart';
import 'package:commerce_server/src/features/admin_order/detail_model.dart';
import 'package:dust_server/server.dart';

const JsonExtractable<AdminCancelFulfillment> _cancellationBody =
    JsonExtractable(AdminCancelFulfillment.fromJson);

/// Cancels one pending order fulfillment.
Future<Result<AdminOrderDetailResponse, Rejection>>
    cancelAdminOrderFulfillmentHandler(Request request) async {
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
  final decoded = await _cancellationBody.extract(request);
  if (decoded case Err(:final error)) return Err(error);
  final state = await adminOrderDeps(request);
  if (state case Err(:final error)) return Err(error);
  final admin = (actor as Ok<AuthenticatedAdmin, Rejection>).value;
  final deps = (state as Ok<AdminOrderDeps, Rejection>).value;
  final result = await cancelAdminOrderFulfillment(
    deps,
    orderId,
    fulfillmentId,
    admin.user.id,
    (decoded as Ok<AdminCancelFulfillment, Rejection>).value,
  );
  return switch (result) {
    Ok(:final value) => Ok(value),
    Err(
      error: AdminCancelFulfillmentRejected(
        failure: AdminCancelFulfillmentFailure.unavailable,
      )
    ) =>
      Err(Rejection.notFound('Order fulfillment')),
    Err(
      error: AdminCancelFulfillmentRejected(
        failure: AdminCancelFulfillmentFailure.invalid,
      )
    ) =>
      const Err(Rejection.status(422, 'Cancellation command is invalid')),
    Err(
      error: AdminCancelFulfillmentRejected(
        failure: AdminCancelFulfillmentFailure.notificationUnavailable,
      )
    ) =>
      const Err(Rejection.status(503, 'Cancellation notification unavailable')),
    Err(
      error: AdminCancelFulfillmentRejected(
        failure: AdminCancelFulfillmentFailure.providerUnavailable,
      )
    ) =>
      const Err(Rejection.status(503, 'Fulfillment provider unavailable')),
    Err(error: AdminCancelFulfillmentStorage()) =>
      const Err(Rejection.internal()),
  };
}
