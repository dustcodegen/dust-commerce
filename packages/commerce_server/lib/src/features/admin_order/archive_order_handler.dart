import 'package:commerce_server/src/features/admin/extractor.dart';
import 'package:commerce_server/src/features/admin_order/archive_order_failure.dart';
import 'package:commerce_server/src/features/admin_order/archive_order_service.dart';
import 'package:commerce_server/src/features/admin_order/deps.dart';
import 'package:commerce_server/src/features/admin_order/detail_model.dart';
import 'package:dust_server/server.dart';

/// `POST /admin/orders/{id}/archive` marks one eligible order archived.
Future<Result<AdminOrderDetailResponse, Rejection>> archiveAdminOrderHandler(
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
  final result = await archiveAdminOrder(deps, orderId);
  return switch (result) {
    Ok(:final value) => Ok(value),
    Err(
      error: AdminArchiveOrderRejected(
        failure: AdminArchiveOrderFailure.unavailable,
      )
    ) =>
      Err(Rejection.notFound('Order')),
    Err(
      error: AdminArchiveOrderRejected(
        failure: AdminArchiveOrderFailure.ineligible,
      )
    ) =>
      const Err(Rejection.status(
        422,
        'Only completed or canceled orders can be archived',
      )),
    Err(error: AdminArchiveOrderStorage()) => const Err(Rejection.internal()),
  };
}
