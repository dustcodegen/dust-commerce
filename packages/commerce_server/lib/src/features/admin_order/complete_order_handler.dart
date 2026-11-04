import 'package:commerce_server/src/features/admin/extractor.dart';
import 'package:commerce_server/src/features/admin_order/complete_order_failure.dart';
import 'package:commerce_server/src/features/admin_order/complete_order_service.dart';
import 'package:commerce_server/src/features/admin_order/deps.dart';
import 'package:commerce_server/src/features/admin_order/detail_model.dart';
import 'package:dust_server/server.dart';

/// `POST /admin/orders/{id}/complete` marks one order completed.
Future<Result<AdminOrderDetailResponse, Rejection>> completeAdminOrderHandler(
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
  final deps = (state as Ok<AdminOrderDeps, Rejection>).value;
  final result = await completeAdminOrder(deps, orderId);
  return switch (result) {
    Ok(:final value) => Ok(value),
    Err(
      error: AdminCompleteOrderRejected(
        failure: AdminCompleteOrderFailure.unavailable,
      )
    ) =>
      Err(Rejection.notFound('Order')),
    Err(
      error: AdminCompleteOrderRejected(
        failure: AdminCompleteOrderFailure.canceled,
      )
    ) =>
      const Err(Rejection.status(422, 'Canceled orders cannot be completed')),
    Err(error: AdminCompleteOrderStorage()) => const Err(Rejection.internal()),
  };
}
