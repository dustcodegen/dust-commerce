import 'package:commerce_server/src/features/admin/extractor.dart';
import 'package:commerce_server/src/features/admin_order/deps.dart';
import 'package:commerce_server/src/features/admin_order/model.dart';
import 'package:commerce_server/src/features/admin_order/query.dart';
import 'package:commerce_server/src/features/admin_order/service.dart';
import 'package:commerce_server/src/http/http.dart';
import 'package:dust_server/server.dart';

/// `GET /admin/orders` — lists immutable order summaries for a proven merchant.
Future<Result<AdminOrderListResponse, Rejection>> listAdminOrdersHandler(
  Request request,
) async {
  final actor = await const Extension<AuthenticatedAdmin>().extract(request);
  if (actor case Err(:final error)) return Err(error);
  final state = await adminOrderDeps(request);
  if (state case Err(:final error)) return Err(error);
  final query = adminOrderQueryOf(request);
  if (query case Err(:final error)) return Err(error);
  final deps = (state as Ok<AdminOrderDeps, Rejection>).value;
  final value = (query as Ok<AdminOrderQuery, Rejection>).value;
  final paging = pagingOf(request);
  final result = await listAdminOrders(
    deps.orders,
    query: value.query,
    statuses: value.statuses,
    regionIds: value.regionIds,
    salesChannelIds: value.salesChannelIds,
    customerId: value.customerId,
    createdAt: value.createdAt,
    updatedAt: value.updatedAt,
    order: value.order,
    limit: paging.limit,
    offset: paging.offset,
  );
  return switch (result) {
    Ok(:final value) => Ok(value),
    Err() => const Err(Rejection.internal()),
  };
}
