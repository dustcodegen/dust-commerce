import 'package:commerce_server/src/features/admin/extractor.dart';
import 'package:commerce_server/src/features/admin_order/deps.dart';
import 'package:commerce_server/src/features/admin_order/detail_model.dart';
import 'package:commerce_server/src/features/admin_order/detail_service.dart';
import 'package:dust_server/server.dart';

/// `GET /admin/orders/{id}` — reads one complete merchant order snapshot.
Future<Result<AdminOrderDetailResponse, Rejection>> readAdminOrderHandler(
  Request request,
) async {
  final actor = await const Extension<AuthenticatedAdmin>().extract(request);
  if (actor case Err(:final error)) return Err(error);
  final id = pathParametersOf(request)['id'];
  if (id == null || id.isEmpty) {
    return const Err(Rejection.badRequest('An order id is required'));
  }
  final state = await adminOrderDeps(request);
  if (state case Err(:final error)) return Err(error);
  final deps = (state as Ok<AdminOrderDeps, Rejection>).value;
  final result = await readAdminOrder(deps.details, id);
  return switch (result) {
    Ok(value: Some(value: final order)) => Ok(order),
    Ok(value: None()) => Err(Rejection.notFound('Order "$id"')),
    Err() => const Err(Rejection.internal()),
  };
}
