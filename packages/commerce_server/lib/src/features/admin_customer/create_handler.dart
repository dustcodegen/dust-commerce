import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin/extractor.dart';
import 'package:commerce_server/src/features/admin_customer/create_failure.dart';
import 'package:commerce_server/src/features/admin_customer/create_service.dart';
import 'package:commerce_server/src/features/admin_customer/deps.dart';
import 'package:commerce_server/src/features/admin_customer/detail_model.dart';
import 'package:commerce_server/src/http/http.dart';
import 'package:dust_server/server.dart';

const ValidatedExtractable<AdminCreateCustomer> _customerBody =
    ValidatedExtractable(
  StrictJsonExtractable<AdminCreateCustomer>(
    AdminCreateCustomer.fromJson,
    fields: {
      'company_name',
      'email',
      'first_name',
      'last_name',
      'phone',
    },
  ),
);

/// `POST /admin/customers` — creates one direct guest customer profile.
Future<Result<AdminCustomerDetailResponse, Rejection>>
    createAdminCustomerHandler(Request request) async {
  final actor = await const Extension<AuthenticatedAdmin>().extract(request);
  if (actor case Err(:final error)) return Err(error);
  final decoded = await _customerBody.extract(request);
  if (decoded case Err(:final error)) return Err(error);
  final state = await adminCustomerDeps(request);
  if (state case Err(:final error)) return Err(error);
  final deps = (state as Ok<AdminCustomerDeps, Rejection>).value;
  final input = (decoded as Ok<AdminCreateCustomer, Rejection>).value;
  final result = await createAdminCustomer(
    deps.creates,
    input,
    nextId: deps.clock.nextId,
  );
  return switch (result) {
    Ok(:final value) => Ok(value),
    Err(error: AdminCreateCustomerRejected()) =>
      const Err(Rejection.conflict('A guest customer already uses this email')),
    Err(error: AdminCreateCustomerStorage()) => const Err(Rejection.internal()),
  };
}
