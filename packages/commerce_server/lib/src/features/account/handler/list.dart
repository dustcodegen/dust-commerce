import 'package:commerce_server/src/features/account/deps.dart';
import 'package:commerce_server/src/features/account/extractor.dart';
import 'package:commerce_server/src/features/account/model.dart';
import 'package:commerce_server/src/features/account/service/service.dart';
import 'package:dust_server/server.dart';

/// `GET /store/customers/me/addresses` — list active owned addresses.
Future<Result<CustomerAddressListResponse, Rejection>> listAddressesHandler(
  Request request,
) async {
  final actor = await request.extract(
    const Extension<AuthenticatedCustomer>(),
  );
  final deps = await request.state<AccountDeps>();
  final result = await listCustomerAddresses(deps.lists, actor.customer.id);
  return switch (result) {
    Ok(:final value) => Ok(CustomerAddressListResponse(
        addresses: value,
        count: value.length,
      )),
    Err() => const Err(Rejection.internal()),
  };
}
