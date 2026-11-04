import 'package:commerce_server/src/features/admin/extractor.dart';
import 'package:commerce_server/src/features/admin_customer_group/deps.dart';
import 'package:commerce_server/src/features/admin_customer_group/list_query.dart';
import 'package:commerce_server/src/features/admin_customer_group/list_response.dart';
import 'package:commerce_server/src/features/admin_customer_group/list_service.dart';
import 'package:commerce_server/src/http/http.dart';
import 'package:dust_server/server.dart';

/// `GET /admin/customer-groups` — lists groups for a proven merchant.
Future<Result<AdminCustomerGroupListResponse, Rejection>>
    listAdminCustomerGroupsHandler(Request request) async {
  final actor = await const Extension<AuthenticatedAdmin>().extract(request);
  if (actor case Err(:final error)) return Err(error);
  final state = await adminCustomerGroupDeps(request);
  if (state case Err(:final error)) return Err(error);
  final query = adminCustomerGroupQueryOf(request);
  if (query case Err(:final error)) return Err(error);
  final deps = (state as Ok<AdminCustomerGroupDeps, Rejection>).value;
  final value = (query as Ok<AdminCustomerGroupQuery, Rejection>).value;
  final paging = pagingOf(request);
  final result = await listAdminCustomerGroups(
    deps.groups,
    query: value.query,
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
