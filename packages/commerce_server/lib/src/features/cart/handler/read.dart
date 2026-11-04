import 'package:commerce_server/src/features/cart/extractor.dart';
import 'package:commerce_server/src/features/cart/model/model.dart';
import 'package:commerce_server/src/features/cart/repository/repository.dart';
import 'package:commerce_server/src/features/cart/service/service.dart';
import 'package:dust_server/server.dart';

/// Loads a cart as the view a client sees, or says why it could not.
///
/// Shared by every endpoint that answers with a cart, so adding a total to
/// [CartViewResponse] reaches all of them without any being edited.
Future<Result<CartViewResponse, Rejection>> cartViewOf(
  CartReadRepository reads,
  String cartId,
) async {
  final loaded = await loadCart(reads, cartId);

  return switch (loaded) {
    Ok(value: Some(value: final cart)) => Ok(CartViewResponse.of(cart)),
    Ok(value: None()) => Err(Rejection.notFound('Cart "$cartId"')),
    Err() => const Err(Rejection.internal()),
  };
}

/// `GET /carts/{id}` — the cart and its totals.
Future<Result<CartViewResponse, Rejection>> readCartHandler(
  Request request,
) async {
  final access = await request.extract(const Extension<CartAccess>());
  return Ok(CartViewResponse.of(access.cart));
}
