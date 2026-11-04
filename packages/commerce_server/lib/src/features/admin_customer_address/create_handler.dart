import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin/extractor.dart';
import 'package:commerce_server/src/features/admin_customer/deps.dart';
import 'package:commerce_server/src/features/admin_customer/detail_model.dart';
import 'package:commerce_server/src/features/admin_customer_address/create_failure.dart';
import 'package:commerce_server/src/features/admin_customer_address/create_service.dart';
import 'package:commerce_server/src/http/http.dart';
import 'package:dust_server/server.dart';

const ValidatedExtractable<AdminCreateCustomerAddress> _addressBody =
    ValidatedExtractable(
  StrictJsonExtractable<AdminCreateCustomerAddress>(
    AdminCreateCustomerAddress.fromJson,
    fields: {
      'address_name',
      'is_default_shipping',
      'is_default_billing',
      'company',
      'first_name',
      'last_name',
      'address_1',
      'address_2',
      'city',
      'country_code',
      'province',
      'postal_code',
      'phone',
    },
  ),
);

/// `POST /admin/customers/{id}/addresses` — adds one reusable destination.
Future<Result<AdminCustomerDetailResponse, Rejection>>
    createAdminCustomerAddressHandler(Request request) async {
  final actor = await const Extension<AuthenticatedAdmin>().extract(request);
  if (actor case Err(:final error)) return Err(error);
  final customerId = pathParametersOf(request)['id'];
  if (customerId == null || customerId.isEmpty) {
    return const Err(Rejection.badRequest('A customer id is required'));
  }
  final decoded = await _addressBody.extract(request);
  if (decoded case Err(:final error)) return Err(error);
  final state = await adminCustomerDeps(request);
  if (state case Err(:final error)) return Err(error);
  final deps = (state as Ok<AdminCustomerDeps, Rejection>).value;
  final input = (decoded as Ok<AdminCreateCustomerAddress, Rejection>).value;
  final result = await createAdminCustomerAddress(
    deps.database,
    customerId,
    input,
    nextId: deps.clock.nextId,
  );
  return switch (result) {
    Ok(:final value) => Ok(value),
    Err(error: AdminCreateCustomerAddressRejected()) =>
      Err(Rejection.notFound('Customer "$customerId"')),
    Err(error: AdminCreateCustomerAddressStorage()) =>
      const Err(Rejection.internal()),
  };
}
