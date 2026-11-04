import 'package:commerce_server/src/features/cart/deps.dart';
import 'package:commerce_server/src/features/cart/extractor.dart';
import 'package:commerce_server/src/features/cart/handler/read.dart';
import 'package:commerce_server/src/features/cart/model/model.dart';
import 'package:commerce_server/src/features/cart/service/service.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_server/server.dart';

const ValidatedExtractable<UpdateCartRegionBody> _body = ValidatedExtractable(
  JsonExtractable(UpdateCartRegionBody.fromJson),
);

/// `PATCH /carts/{id}` — replace the cart's selling region atomically.
Future<Result<CartViewResponse, Rejection>> updateCartRegionHandler(
  Request request,
) async {
  final access = await request.extract(const Extension<CartAccess>());
  final decoded = await _body.extract(request);
  if (decoded case Err(:final error)) return Err(error);
  final body = (decoded as Ok<UpdateCartRegionBody, Rejection>).value;

  final state = await cartDeps(request);
  if (state case Err(:final error)) return Err(error);
  final deps = (state as Ok<CartDeps, Rejection>).value;
  final changed = await updateCartRegion(
    deps.database,
    cartId: access.cart.id,
    regionId: body.regionId,
    now: deps.clock.now(),
  );

  return switch (changed) {
    Ok(value: None()) => await cartViewOf(deps.reads, access.cart.id),
    Ok(value: Some(value: UpdateCartRegionFailure.noCart)) =>
      Err(Rejection.notFound('Cart "${access.cart.id}"')),
    Ok(value: Some(value: UpdateCartRegionFailure.noRegion)) => Err(
        Rejection.status(422, 'Region "${body.regionId}" does not exist'),
      ),
    Ok(value: Some(value: UpdateCartRegionFailure.unavailableLines)) =>
      const Err(
        Rejection.status(
          422,
          'One or more cart items are not available in that region',
        ),
      ),
    Err() => const Err(Rejection.internal()),
  };
}
