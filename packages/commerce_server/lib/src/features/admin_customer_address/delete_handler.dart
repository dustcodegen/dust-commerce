import 'package:commerce_server/src/features/admin/extractor.dart';
import 'package:commerce_server/src/features/admin_customer/deps.dart';
import 'package:commerce_server/src/features/admin_customer_address/delete_failure.dart';
import 'package:commerce_server/src/features/admin_customer_address/delete_response.dart';
import 'package:commerce_server/src/features/admin_customer_address/delete_service.dart';
import 'package:dust_server/server.dart';

/// `DELETE /admin/customers/{id}/addresses/{address_id}` — removes an address.
Future<Result<AdminCustomerAddressDeleteResponse, Rejection>>
    deleteAdminCustomerAddressHandler(Request request) async {
  final actor = await const Extension<AuthenticatedAdmin>().extract(request);
  if (actor case Err(:final error)) return Err(error);
  final path = pathParametersOf(request);
  final customerId = path['id'];
  final addressId = path['address_id'];
  if (customerId == null || customerId.isEmpty) {
    return const Err(Rejection.badRequest('A customer id is required'));
  }
  if (addressId == null || addressId.isEmpty) {
    return const Err(Rejection.badRequest('An address id is required'));
  }
  final state = await adminCustomerDeps(request);
  if (state case Err(:final error)) return Err(error);
  final deps = (state as Ok<AdminCustomerDeps, Rejection>).value;
  return switch (await deleteAdminCustomerAddress(
    deps.database,
    customerId,
    addressId,
  )) {
    Ok(:final value) => Ok(value),
    Err(error: AdminDeleteCustomerAddressRejected()) =>
      Err(Rejection.notFound('Address "$addressId"')),
    Err(error: AdminDeleteCustomerAddressStorage()) =>
      const Err(Rejection.internal()),
  };
}
