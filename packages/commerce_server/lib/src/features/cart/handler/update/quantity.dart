import 'package:commerce_server/src/features/cart/deps.dart';
import 'package:commerce_server/src/features/cart/extractor.dart';
import 'package:commerce_server/src/features/cart/handler/read.dart';
import 'package:commerce_server/src/features/cart/model/model.dart';
import 'package:commerce_server/src/features/cart/service/service.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_server/server.dart';

const ValidatedExtractable<UpdateLineBody> _body =
    ValidatedExtractable(JsonExtractable(UpdateLineBody.fromJson));

/// `PATCH /carts/{id}/line-items/{lineId}` — replace a line quantity.
Future<Result<CartViewResponse, Rejection>> updateLineHandler(
  Request request,
) async {
  final access = await request.extract(const Extension<CartAccess>());
  final lineId = pathParametersOf(request)['lineId'];
  if (lineId == null || lineId.isEmpty) {
    return const Err(Rejection.badRequest('A line id is required'));
  }

  final decoded = await _body.extract(request);
  if (decoded case Err(:final error)) return Err(error);
  final body = (decoded as Ok<UpdateLineBody, Rejection>).value;

  final state = await cartDeps(request);
  if (state case Err(:final error)) return Err(error);
  final deps = (state as Ok<CartDeps, Rejection>).value;
  final result = await updateLineQuantity(
    deps.database,
    cartId: access.cart.id,
    lineId: lineId,
    quantity: body.quantity,
  );

  return switch (result) {
    Ok(value: None()) => await cartViewOf(deps.reads, access.cart.id),
    Ok(value: Some(value: UpdateLineFailure.noLine)) =>
      Err(Rejection.notFound('Cart line "$lineId"')),
    Ok(value: Some(value: UpdateLineFailure.unavailable)) =>
      Err(Rejection.conflict('This item is no longer available')),
    Ok(value: Some(value: UpdateLineFailure.outOfStock)) =>
      Err(Rejection.conflict('Not enough stock for this quantity')),
    Err() => const Err(Rejection.internal()),
  };
}
