import 'package:commerce_server/src/features/admin/extractor.dart';
import 'package:commerce_server/src/features/admin_order/cancel_order_failure.dart';
import 'package:commerce_server/src/features/admin_order/cancel_order_service.dart';
import 'package:commerce_server/src/features/admin_order/deps.dart';
import 'package:commerce_server/src/features/admin_order/detail_model.dart';
import 'package:dust_server/server.dart';

/// `POST /admin/orders/{id}/cancel` cancels one eligible order.
Future<Result<AdminOrderDetailResponse, Rejection>> cancelAdminOrderHandler(
  Request request,
) async {
  final actor = await const Extension<AuthenticatedAdmin>().extract(request);
  if (actor case Err(:final error)) return Err(error);
  final orderId = pathParametersOf(request)['id'];
  if (orderId == null || orderId.isEmpty) {
    return const Err(Rejection.badRequest('An order id is required'));
  }
  final state = await adminOrderDeps(request);
  if (state case Err(:final error)) return Err(error);
  final admin = (actor as Ok<AuthenticatedAdmin, Rejection>).value;
  final deps = (state as Ok<AdminOrderDeps, Rejection>).value;
  final result = await cancelAdminOrder(deps, orderId, admin.user.id);
  return switch (result) {
    Ok(:final value) => Ok(value),
    Err(
      error: AdminCancelOrderRejected(
        failure: AdminCancelOrderFailure.unavailable,
      )
    ) =>
      Err(Rejection.notFound('Order')),
    Err(
      error: AdminCancelOrderRejected(
        failure: AdminCancelOrderFailure.alreadyCanceled,
      )
    ) =>
      const Err(Rejection.status(422, 'Order is already canceled')),
    Err(
      error: AdminCancelOrderRejected(
        failure: AdminCancelOrderFailure.completed,
      )
    ) =>
      const Err(Rejection.status(
        422,
        'Cannot cancel a completed order. Use the return process.',
      )),
    Err(
      error: AdminCancelOrderRejected(
        failure: AdminCancelOrderFailure.activeFulfillments,
      )
    ) =>
      const Err(Rejection.status(
        422,
        'All fulfillments must be canceled before canceling an order',
      )),
    Err(
      error: AdminCancelOrderRejected(
        failure: AdminCancelOrderFailure.providerUnavailable,
      )
    ) =>
      const Err(Rejection.status(503, 'Payment provider unavailable')),
    Err(
      error: AdminCancelOrderRejected(
        failure: AdminCancelOrderFailure.invalidPayment,
      )
    ) =>
      const Err(Rejection.conflict('Order payment requires reconciliation')),
    Err(error: AdminCancelOrderStorage()) => const Err(Rejection.internal()),
  };
}
