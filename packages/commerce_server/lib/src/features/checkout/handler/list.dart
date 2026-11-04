import 'package:commerce_server/src/features/account/extractor.dart';
import 'package:commerce_server/src/features/checkout/deps.dart';
import 'package:commerce_server/src/features/checkout/model.dart';
import 'package:dust_dart/db.dart';
import 'package:dust_server/server.dart';

/// `GET /orders` — the authenticated customer's orders.
Future<Result<OrderListResponse, Rejection>> listOrdersHandler(
  Request request,
) async {
  final actor = await request.extract(
    const Extension<AuthenticatedCustomer>(),
  );

  final state = await checkoutDeps(request);
  if (state case Err(:final error)) return Err(error);
  final deps = (state as Ok<CheckoutDeps, Rejection>).value;

  final found = await deps.lists.ordersForCustomer(actor.customer.id);
  if (found case Err()) return const Err(Rejection.internal());
  final orders = (found as Ok<List<OrderResponse>, SqlxError>).value;
  return Ok(OrderListResponse.of(orders));
}
