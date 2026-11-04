import 'package:commerce_server/src/features/cart/deps.dart';
import 'package:commerce_server/src/features/cart/extractor.dart';
import 'package:commerce_server/src/features/cart/handler/read.dart';
import 'package:commerce_server/src/features/cart/model/model.dart';
import 'package:commerce_server/src/features/cart/service/service.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_server/server.dart';

const ValidatedExtractable<ApplyPromotionBody> _body = ValidatedExtractable(
  JsonExtractable<ApplyPromotionBody>(ApplyPromotionBody.fromJson),
);

/// `POST /carts/{id}/promotions` — apply a code.
///
/// An unknown code and an expired one answer differently. Telling a customer
/// "that code does not exist" when it has merely finished is how a support
/// queue fills with people who typed it correctly.
Future<Result<CartViewResponse, Rejection>> applyPromotionHandler(
  Request request,
) async {
  final access = await request.extract(const Extension<CartAccess>());
  final cartId = access.cart.id;

  final decoded = await _body.extract(request);
  if (decoded case Err(:final error)) return Err(error);
  final body = (decoded as Ok<ApplyPromotionBody, Rejection>).value;

  final state = await cartDeps(request);
  if (state case Err(:final error)) return Err(error);
  final deps = (state as Ok<CartDeps, Rejection>).value;

  final result = await applyPromotion(
    deps.reads,
    deps.writes,
    cartId: cartId,
    code: body.code,
    now: deps.clock.now(),
  );

  return switch (result) {
    Ok(value: None()) => await cartViewOf(deps.reads, cartId),
    Ok(value: Some(value: ApplyPromotionFailure.noCart)) =>
      Err(Rejection.notFound('Cart "$cartId"')),
    Ok(value: Some(value: ApplyPromotionFailure.noPromotion)) => Err(
        Rejection.status(
          422,
          'There is no promotion with the code "${body.code}"',
        ),
      ),
    Ok(value: Some(value: ApplyPromotionFailure.notUsable)) =>
      Err(Rejection.status(422, 'The code "${body.code}" is not available')),
    Ok(value: Some(value: ApplyPromotionFailure.wrongCurrency)) => Err(
        Rejection.status(
          422,
          'The code "${body.code}" cannot be used in this currency',
        ),
      ),
    Err() => const Err(Rejection.internal()),
  };
}

/// `DELETE /carts/{id}/promotions` — take the code off again.
Future<Result<CartViewResponse, Rejection>> removePromotionHandler(
  Request request,
) async {
  final access = await request.extract(const Extension<CartAccess>());
  final cartId = access.cart.id;

  final state = await cartDeps(request);
  if (state case Err(:final error)) return Err(error);
  final deps = (state as Ok<CartDeps, Rejection>).value;

  final result = await removePromotion(deps.reads, deps.writes, cartId);

  return switch (result) {
    Ok(value: true) => await cartViewOf(deps.reads, cartId),
    Ok() => Err(Rejection.notFound('Cart "$cartId"')),
    Err() => const Err(Rejection.internal()),
  };
}
