import 'package:commerce_server/src/features/admin/extractor.dart';
import 'package:commerce_server/src/features/admin_customer_service/deps.dart';
import 'package:commerce_server/src/features/admin_customer_service/model.dart';
import 'package:commerce_server/src/features/admin_customer_service/query.dart';
import 'package:commerce_server/src/features/admin_customer_service/service/list.dart';
import 'package:commerce_server/src/http/http.dart';
import 'package:dust_server/server.dart';

/// `GET /admin/customer-service` — lists requests for a proven merchant.
Future<Result<AdminCustomerServiceListResponse, Rejection>>
    listAdminCustomerServiceHandler(Request request) async {
  final actor = await const Extension<AuthenticatedAdmin>().extract(request);
  if (actor case Err(:final error)) return Err(error);
  final state = await adminCustomerServiceDeps(request);
  if (state case Err(:final error)) return Err(error);
  final query = adminCustomerServiceQueryOf(request);
  if (query case Err(:final error)) return Err(error);
  final deps = (state as Ok<AdminCustomerServiceDeps, Rejection>).value;
  final value = (query as Ok<AdminCustomerServiceQuery, Rejection>).value;
  final paging = pagingOf(request);
  final result = await listAdminCustomerService(
    deps.requests,
    query: value.query,
    statuses: value.statuses,
    order: value.order,
    limit: paging.limit,
    offset: paging.offset,
  );
  return switch (result) {
    Ok(:final value) => Ok(value),
    Err() => const Err(Rejection.internal()),
  };
}
