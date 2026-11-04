import 'package:commerce_server/src/features/account/extractor.dart';
import 'package:commerce_server/src/features/account/model.dart';
import 'package:dust_server/server.dart';

/// `GET /store/customers/me` — return the authenticated customer.
Future<Result<CustomerResponse, Rejection>> readCurrentCustomerHandler(
  Request request,
) async {
  final actor = await request.extract(
    const Extension<AuthenticatedCustomer>(),
  );
  return Ok(actor.customer);
}
