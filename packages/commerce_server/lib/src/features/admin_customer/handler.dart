import 'package:commerce_server/src/features/admin/extractor.dart';
import 'package:commerce_server/src/features/admin_customer/deps.dart';
import 'package:commerce_server/src/features/admin_customer/model.dart';
import 'package:commerce_server/src/features/admin_customer/query.dart';
import 'package:commerce_server/src/features/admin_customer/service.dart';
import 'package:commerce_server/src/http/http.dart';
import 'package:dust_server/server.dart';

/// `GET /admin/customers` — lists customer summaries for a proven merchant.
Future<Result<AdminCustomerListResponse, Rejection>> listAdminCustomersHandler(
  Request request,
) async {
  final actor = await const Extension<AuthenticatedAdmin>().extract(request);
  if (actor case Err(:final error)) return Err(error);
  final state = await adminCustomerDeps(request);
  if (state case Err(:final error)) return Err(error);
  final query = adminCustomerQueryOf(request);
  if (query case Err(:final error)) return Err(error);
  final deps = (state as Ok<AdminCustomerDeps, Rejection>).value;
  final value = (query as Ok<AdminCustomerQuery, Rejection>).value;
  final paging = pagingOf(request);
  final result = await listAdminCustomers(
    deps.customers,
    query: value.query,
    groupId: value.groupId,
    hasAccount: value.hasAccount,
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
