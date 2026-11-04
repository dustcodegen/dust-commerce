import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin/extractor.dart';
import 'package:commerce_server/src/features/admin_customer/deps.dart';
import 'package:commerce_server/src/features/admin_customer/detail_model.dart';
import 'package:commerce_server/src/features/admin_customer/update_failure.dart';
import 'package:commerce_server/src/features/admin_customer/update_service.dart';
import 'package:commerce_server/src/http/http.dart';
import 'package:dust_server/server.dart';

const ValidatedExtractable<AdminUpdateCustomer> _customerBody =
    ValidatedExtractable(
  StrictJsonExtractable<AdminUpdateCustomer>(
    AdminUpdateCustomer.fromJson,
    fields: {
      'company_name',
      'email',
      'first_name',
      'last_name',
      'phone',
    },
  ),
);

/// `PATCH /admin/customers/{id}` — replaces editable customer contact fields.
Future<Result<AdminCustomerDetailResponse, Rejection>>
    updateAdminCustomerHandler(Request request) async {
  final actor = await const Extension<AuthenticatedAdmin>().extract(request);
  if (actor case Err(:final error)) return Err(error);
  final id = pathParametersOf(request)['id'];
  if (id == null || id.isEmpty) {
    return const Err(Rejection.badRequest('A customer id is required'));
  }
  final decoded = await _customerBody.extract(request);
  if (decoded case Err(:final error)) return Err(error);
  final state = await adminCustomerDeps(request);
  if (state case Err(:final error)) return Err(error);
  final deps = (state as Ok<AdminCustomerDeps, Rejection>).value;
  final input = (decoded as Ok<AdminUpdateCustomer, Rejection>).value;
  final result = await updateAdminCustomer(deps.database, id, input);
  return switch (result) {
    Ok(:final value) => Ok(value),
    Err(
      error: AdminUpdateCustomerRejected(
        failure: AdminUpdateCustomerFailure.notFound,
      )
    ) =>
      Err(Rejection.notFound('Customer "$id"')),
    Err(
      error: AdminUpdateCustomerRejected(
        failure: AdminUpdateCustomerFailure.emailRequired,
      )
    ) =>
      const Err(Rejection.status(422, 'A guest customer email is required')),
    Err(
      error: AdminUpdateCustomerRejected(
        failure: AdminUpdateCustomerFailure.registeredEmail,
      )
    ) =>
      const Err(Rejection.conflict('Registered customer email is read-only')),
    Err(
      error: AdminUpdateCustomerRejected(
        failure: AdminUpdateCustomerFailure.emailConflict,
      )
    ) =>
      const Err(Rejection.conflict('Another customer uses this email')),
    Err(error: AdminUpdateCustomerStorage()) => const Err(Rejection.internal()),
  };
}
