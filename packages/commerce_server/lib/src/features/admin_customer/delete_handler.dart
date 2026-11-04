import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin/extractor.dart';
import 'package:commerce_server/src/features/admin_customer/delete_failure.dart';
import 'package:commerce_server/src/features/admin_customer/delete_service.dart';
import 'package:commerce_server/src/features/admin_customer/deps.dart';
import 'package:dust_server/server.dart';

/// `DELETE /admin/customers/{id}` — removes one customer account boundary.
Future<Result<AdminCustomerDeleted, Rejection>> deleteAdminCustomerHandler(
  Request request,
) async {
  final actor = await const Extension<AuthenticatedAdmin>().extract(request);
  if (actor case Err(:final error)) return Err(error);
  final id = pathParametersOf(request)['id'];
  if (id == null || id.isEmpty) {
    return const Err(Rejection.badRequest('A customer id is required'));
  }
  final state = await adminCustomerDeps(request);
  if (state case Err(:final error)) return Err(error);
  final deps = (state as Ok<AdminCustomerDeps, Rejection>).value;
  return switch (await deleteAdminCustomer(deps.database, id)) {
    Ok(:final value) => Ok(value),
    Err(
      error: AdminDeleteCustomerRejected(
        failure: AdminDeleteCustomerFailure.notFound,
      )
    ) =>
      Err(Rejection.notFound('Customer "$id"')),
    Err(error: AdminDeleteCustomerRejected()) =>
      const Err(Rejection.internal()),
    Err(error: AdminDeleteCustomerStorage()) => const Err(Rejection.internal()),
  };
}
