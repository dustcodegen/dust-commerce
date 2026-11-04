import 'package:commerce_server/src/features/cart/deps.dart';
import 'package:commerce_server/src/features/cart/extractor.dart';
import 'package:commerce_server/src/features/cart/handler/read.dart';
import 'package:commerce_server/src/features/cart/model/model.dart';
import 'package:commerce_server/src/features/cart/service/service.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_server/server.dart';

const ValidatedExtractable<ChooseShippingBody> _body = ValidatedExtractable(
  JsonExtractable<ChooseShippingBody>(ChooseShippingBody.fromJson),
);

/// `POST /carts/{id}/shipping-method` — choose how the goods travel.
Future<Result<CartViewResponse, Rejection>> chooseShippingHandler(
  Request request,
) async {
  final access = await request.extract(const Extension<CartAccess>());
  final cartId = access.cart.id;

  final decoded = await _body.extract(request);
  if (decoded case Err(:final error)) return Err(error);
  final body = (decoded as Ok<ChooseShippingBody, Rejection>).value;

  final state = await cartDeps(request);
  if (state case Err(:final error)) return Err(error);
  final deps = (state as Ok<CartDeps, Rejection>).value;

  final result = await chooseShipping(
    deps.reads,
    deps.lists,
    deps.shipping,
    cartId: cartId,
    optionId: body.optionId,
  );

  return switch (result) {
    Ok(value: None()) => await cartViewOf(deps.reads, cartId),
    Ok(value: Some(value: ChooseShippingFailure.noCart)) =>
      Err(Rejection.notFound('Cart "$cartId"')),
    Ok(value: Some(value: ChooseShippingFailure.noOption)) => Err(
        Rejection.status(
          422,
          'Shipping option "${body.optionId}" is not offered here',
        ),
      ),
    Ok(value: Some(value: ChooseShippingFailure.notEligible)) => Err(
        Rejection.status(
          422,
          'Shipping option "${body.optionId}" does not apply to this cart yet',
        ),
      ),
    Err() => const Err(Rejection.internal()),
  };
}
