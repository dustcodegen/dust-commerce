import 'package:commerce_server/src/features/admin/extractor.dart';
import 'package:commerce_server/src/features/admin_customer_group/deps.dart';
import 'package:commerce_server/src/features/admin_customer_group/detail_response.dart';
import 'package:commerce_server/src/features/admin_customer_group/service/read.dart';
import 'package:dust_server/server.dart';

/// `GET /admin/customer-groups/{id}` — reads one active merchant segment.
Future<Result<AdminCustomerGroupDetailResult, Rejection>>
    readAdminCustomerGroupHandler(Request request) async {
  final actor = await const Extension<AuthenticatedAdmin>().extract(request);
  if (actor case Err(:final error)) return Err(error);
  final id = pathParametersOf(request)['id'];
  if (id == null || id.isEmpty) {
    return const Err(Rejection.badRequest('A customer-group id is required'));
  }
  final state = await adminCustomerGroupDeps(request);
  if (state case Err(:final error)) return Err(error);
  final deps = (state as Ok<AdminCustomerGroupDeps, Rejection>).value;
  final result = await readAdminCustomerGroup(deps.details, id);
  return switch (result) {
    Ok(value: Some(:final value)) => Ok(value),
    Ok(value: None()) => Err(Rejection.notFound('Customer group "$id"')),
    Err() => const Err(Rejection.internal()),
  };
}
