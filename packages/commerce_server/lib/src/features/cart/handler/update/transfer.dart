import 'package:commerce_server/src/features/account/extractor.dart';
import 'package:commerce_server/src/features/cart/deps.dart';
import 'package:commerce_server/src/features/cart/model/model.dart';
import 'package:commerce_server/src/features/cart/service/service.dart';
import 'package:dust_server/server.dart';

/// `POST /carts/{id}/transfer` - attach a guest cart to the signed-in customer.
Future<Result<CartViewResponse, Rejection>> transferCartHandler(
  Request request,
) async {
  final actor = await request.extract(const Extension<AuthenticatedCustomer>());
  final cartId = pathParametersOf(request)['id'];
  if (cartId == null || cartId.isEmpty) {
    return const Err(Rejection.badRequest('A cart id is required'));
  }
  final state = await cartDeps(request);
  if (state case Err(:final error)) return Err(error);
  final deps = (state as Ok<CartDeps, Rejection>).value;

  final transferred = await transferCart(
    deps.reads,
    deps.writes,
    cartId: cartId,
    customerId: actor.customer.id,
    email: actor.customer.email,
  );
  return switch (transferred) {
    Ok(value: Some(value: final cart)) => Ok(CartViewResponse.of(cart)),
    Ok(value: None()) => Err(Rejection.notFound('Cart "$cartId"')),
    Err() => const Err(Rejection.internal()),
  };
}
