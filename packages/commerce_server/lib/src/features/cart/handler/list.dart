import 'package:commerce_server/src/features/cart/deps.dart';
import 'package:commerce_server/src/features/cart/extractor.dart';
import 'package:commerce_server/src/features/cart/model/model.dart';
import 'package:commerce_server/src/features/cart/service/service.dart';
import 'package:dust_server/server.dart';

/// `GET /carts/{id}/shipping-options` — what this cart may choose from.
Future<Result<ShippingOptionsResponse, Rejection>> listShippingOptionsHandler(
  Request request,
) async {
  final access = await request.extract(const Extension<CartAccess>());
  final cartId = access.cart.id;

  final state = await cartDeps(request);
  if (state case Err(:final error)) return Err(error);
  final deps = (state as Ok<CartDeps, Rejection>).value;

  final result = await shippingOptionsFor(deps.reads, deps.lists, cartId);

  return switch (result) {
    Ok(value: Some(value: final options)) =>
      Ok(ShippingOptionsResponse.of(options)),
    Ok(value: None()) => Err(Rejection.notFound('Cart "$cartId"')),
    Err() => const Err(Rejection.internal()),
  };
}
