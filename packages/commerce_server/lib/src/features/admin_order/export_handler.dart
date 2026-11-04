import 'dart:convert';

import 'package:commerce_server/src/features/admin/extractor.dart';
import 'package:commerce_server/src/features/admin_order/deps.dart';
import 'package:commerce_server/src/features/admin_order/export_service.dart';
import 'package:commerce_server/src/features/admin_order/query.dart';
import 'package:dust_server/server.dart';

/// `GET /admin/orders/export` — downloads the complete filtered order set.
Future<Result<Response, Rejection>> exportAdminOrdersHandler(
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
  final result = await exportAdminOrders(
    deps.exports,
    query: value.query,
    statuses: value.statuses,
    regionIds: value.regionIds,
    salesChannelIds: value.salesChannelIds,
    createdAt: value.createdAt,
    updatedAt: value.updatedAt,
    order: value.order,
  );
  return switch (result) {
    Ok(:final value) => Ok(streamed(
        Stream.value(utf8.encode(value)),
        contentType: 'text/csv; charset=utf-8',
        headers: const {
          'content-disposition': 'attachment; filename="order-export.csv"',
        },
      )),
    Err() => const Err(Rejection.internal()),
  };
}
