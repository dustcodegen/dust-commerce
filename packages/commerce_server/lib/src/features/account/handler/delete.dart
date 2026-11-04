import 'package:commerce_server/src/features/account/deps.dart';
import 'package:commerce_server/src/features/account/extractor.dart';
import 'package:commerce_server/src/features/account/service/service.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_server/server.dart';

/// `DELETE /auth/session` — revoke the current bearer token.
Future<Result<SessionDeleted, Rejection>> signOutHandler(
  Request request,
) async {
  final deps = await request.state<AccountDeps>();
  final actor = await request.extract(
    const Extension<AuthenticatedCustomer>(),
  );
  final revoked = await signOut(deps.deletes, actor.token);
  if (revoked case Err()) return const Err(Rejection.internal());
  return const Ok(SessionDeleted(success: true));
}

/// `DELETE /store/customers/me/addresses/{addressId}` — remove an owned row.
Future<Result<CustomerAddressDeleted, Rejection>> deleteAddressHandler(
  Request request,
) async {
  final addressId = pathParametersOf(request)['addressId'];
  if (addressId == null || addressId.isEmpty) {
    return const Err(Rejection.badRequest('An address id is required'));
  }
  final deps = await request.state<AccountDeps>();
  final actor = await request.extract(
    const Extension<AuthenticatedCustomer>(),
  );
  final result = await deleteCustomerAddress(
    deps.deletes,
    addressId,
    actor.customer.id,
  );
  return switch (result) {
    Ok(value: true) => Ok(CustomerAddressDeleted(
        id: addressId,
        success: true,
      )),
    Ok(value: false) => const Err(Rejection.notFound('Address')),
    Err() => const Err(Rejection.internal()),
  };
}
