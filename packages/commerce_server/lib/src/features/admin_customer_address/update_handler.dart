import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin/extractor.dart';
import 'package:commerce_server/src/features/admin_customer/deps.dart';
import 'package:commerce_server/src/features/admin_customer/detail_model.dart';
import 'package:commerce_server/src/features/admin_customer_address/update_service.dart';
import 'package:commerce_server/src/http/http.dart';
import 'package:dust_server/server.dart';

const StrictJsonExtractable<AdminUpdateCustomerAddress> _addressBody =
    StrictJsonExtractable(
  AdminUpdateCustomerAddress.fromJson,
  fields: AdminUpdateCustomerAddress.jsonFields,
);

/// `POST /admin/customers/{id}/addresses/{address_id}` — patches an address.
Future<Result<AdminCustomerDetailResponse, Rejection>>
    updateAdminCustomerAddressHandler(Request request) async {
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
  final decoded = await _addressBody.extract(request);
  if (decoded case Err(:final error)) return Err(error);
  final state = await adminCustomerDeps(request);
  if (state case Err(:final error)) return Err(error);
  final deps = (state as Ok<AdminCustomerDeps, Rejection>).value;
  final input = (decoded as Ok<AdminUpdateCustomerAddress, Rejection>).value;
  return switch (await updateAdminCustomerAddress(
    deps.database,
    customerId,
    addressId,
    input,
  )) {
    Ok(value: Some(:final value)) => Ok(value),
    Ok(value: None()) => Err(Rejection.notFound('Address "$addressId"')),
    Err() => const Err(Rejection.internal()),
  };
}
