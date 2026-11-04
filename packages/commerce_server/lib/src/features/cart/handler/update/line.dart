import 'package:commerce_server/src/features/cart/deps.dart';
import 'package:commerce_server/src/features/cart/extractor.dart';
import 'package:commerce_server/src/features/cart/handler/read.dart';
import 'package:commerce_server/src/features/cart/model/model.dart';
import 'package:commerce_server/src/features/cart/service/service.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_server/server.dart';

const ValidatedExtractable<AddLineBody> _body =
    ValidatedExtractable(JsonExtractable<AddLineBody>(AddLineBody.fromJson));

/// `POST /carts/{id}/line-items` — add a variant to the cart.
///
/// The three outcomes are deliberately different statuses. A missing cart is a
/// 404 about the thing in the path; an unknown variant is a 422 about the
/// body; running out of stock is a 409, because somebody buying the last one
/// is an ordinary outcome of a shop rather than a malformed request.
Future<Result<CartViewResponse, Rejection>> addLineHandler(
    Request request) async {
  final access = await request.extract(const Extension<CartAccess>());
  final cartId = access.cart.id;

  final decoded = await _body.extract(request);
  if (decoded case Err(:final error)) return Err(error);
  final body = (decoded as Ok<AddLineBody, Rejection>).value;

  final state = await cartDeps(request);
  if (state case Err(:final error)) return Err(error);
  final deps = (state as Ok<CartDeps, Rejection>).value;

  final result = await addLine(
    deps.database,
    cartId: cartId,
    variantId: body.variantId,
    quantity: body.quantity,
    nextId: deps.clock.nextId,
  );

  return switch (result) {
    Ok(value: None()) => await cartViewOf(deps.reads, cartId),
    Ok(value: Some(value: AddLineFailure.noCart)) =>
      Err(Rejection.notFound('Cart "$cartId"')),
    Ok(value: Some(value: AddLineFailure.noVariant)) => Err(
        Rejection.status(
          422,
          'Variant "${body.variantId}" is not on sale in this currency',
        ),
      ),
    Ok(value: Some(value: AddLineFailure.outOfStock)) =>
      Err(Rejection.conflict('Not enough stock for "${body.variantId}"')),
    Err() => const Err(Rejection.internal()),
  };
}
