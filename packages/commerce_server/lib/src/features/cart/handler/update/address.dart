import 'package:commerce_server/src/features/cart/deps.dart';
import 'package:commerce_server/src/features/cart/extractor.dart';
import 'package:commerce_server/src/features/cart/handler/read.dart';
import 'package:commerce_server/src/features/cart/model/model.dart';
import 'package:commerce_server/src/features/cart/service/service.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_server/server.dart';

const ValidatedExtractable<UpdateCartAddressesBody> _body =
    ValidatedExtractable(
  JsonExtractable<UpdateCartAddressesBody>(UpdateCartAddressesBody.fromJson),
);

/// `PUT /carts/{id}/addresses` — retain the completed address step.
Future<Result<CartViewResponse, Rejection>> updateCartAddressesHandler(
  Request request,
) async {
  final access = await request.extract(const Extension<CartAccess>());
  final decoded = await _body.extract(request);
  if (decoded case Err(:final error)) return Err(error);
  final body = (decoded as Ok<UpdateCartAddressesBody, Rejection>).value;
  final state = await cartDeps(request);
  if (state case Err(:final error)) return Err(error);
  final deps = (state as Ok<CartDeps, Rejection>).value;
  final result = await updateCartAddresses(
    deps.database,
    cartId: access.cart.id,
    email: access.customer.match(
      some: (actor) => actor.customer.email,
      none: () => body.email,
    ),
    shipping: body.shippingAddress.toAddress(),
    billing: body.billingAddress?.toAddress(),
  );
  return switch (result) {
    Ok(value: None()) => await cartViewOf(deps.reads, access.cart.id),
    Ok(value: Some(value: CartAddressFailure.noCart)) =>
      Err(Rejection.notFound('Cart "${access.cart.id}"')),
    Ok(value: Some(value: CartAddressFailure.countryNotInRegion)) => const Err(
        Rejection.status(422, 'Address country is not served by this cart'),
      ),
    Err() => const Err(Rejection.internal()),
  };
}
