import 'package:commerce_server/src/features/account/extractor.dart';
import 'package:commerce_server/src/features/cart/deps.dart';
import 'package:commerce_server/src/features/cart/handler/read.dart';
import 'package:commerce_server/src/features/cart/model/model.dart';
import 'package:commerce_server/src/features/cart/service/service.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_server/server.dart';

/// The body of a create, when one was sent.
///
/// A body is optional: `POST /carts` with nothing starts a cart in the default
/// region, which is what a storefront does before it knows where the customer
/// is.
const OptionalExtractable<CreateCartBody> _body = OptionalExtractable(
  ValidatedExtractable(
    JsonExtractable<CreateCartBody>(CreateCartBody.fromJson),
  ),
);

/// `POST /carts` — start an empty cart.
///
/// Answers with a [CartView] like every other cart endpoint, so a client has
/// one shape to decode whether it created the cart or fetched it.
Future<Result<CartViewResponse, Rejection>> createCartHandler(
  Request request,
) async {
  final context = await request.extract(const Extension<CustomerContext>());
  final actor = context.authenticated;
  final decoded = await _body.extract(request);
  if (decoded case Err(:final error)) return Err(error);

  final body =
      switch ((decoded as Ok<Option<CreateCartBody>, Rejection>).value) {
    Some(value: final sent) => sent,
    None() => const CreateCartBody(),
  };

  final state = await cartDeps(request);
  if (state case Err(:final error)) return Err(error);
  final deps = (state as Ok<CartDeps, Rejection>).value;

  final result = await createCart(
    deps.database,
    id: deps.clock.nextId(),
    regionId: body.regionId,
    email: actor.match(
      some: (value) => value.customer.email,
      none: () => body.email,
    ),
    customerId: actor.match(
      some: (value) => value.customer.id,
      none: () => null,
    ),
  );

  return switch (result) {
    Ok(value: Some(value: final cart)) => Ok(CartViewResponse.of(cart)),
    Ok(value: None()) when body.regionId != null =>
      Err(Rejection.status(422, 'Region "${body.regionId}" does not exist')),
    Ok(value: None()) => const Err(
        Rejection.status(503, 'The shop has no region configured'),
      ),
    Err() => const Err(Rejection.internal()),
  };
}

const ValidatedExtractable<BuyCartBody> _buyBody = ValidatedExtractable(
  JsonExtractable<BuyCartBody>(BuyCartBody.fromJson),
);

/// `POST /carts/buy` — atomically create a cart from a checkout permalink.
Future<Result<CartViewResponse, Rejection>> buyCartHandler(
  Request request,
) async {
  final context = await request.extract(const Extension<CustomerContext>());
  final decoded = await _buyBody.extract(request);
  if (decoded case Err(:final error)) return Err(error);
  final body = (decoded as Ok<BuyCartBody, Rejection>).value;
  if (body.items.any((item) => !item.validate().isValid)) {
    return const Err(Rejection.status(422, 'One or more items are invalid'));
  }
  final state = await cartDeps(request);
  if (state case Err(:final error)) return Err(error);
  final deps = (state as Ok<CartDeps, Rejection>).value;
  final result = await buyCart(
    deps.database,
    id: deps.clock.nextId(),
    items: body.items,
    regionId: body.regionId,
    customerId: context.authenticated.match(
      some: (value) => value.customer.id,
      none: () => null,
    ),
    email: context.authenticated.match(
      some: (value) => value.customer.email,
      none: () => null,
    ),
    nextId: deps.clock.nextId,
  );
  return switch (result) {
    Err() => const Err(Rejection.internal()),
    Ok(value: BuyCartReady(:final cartId)) => cartViewOf(deps.reads, cartId),
    Ok(value: BuyCartRejected(:final failure, :final variantId)) =>
      _buyRejection(failure, variantId),
  };
}

Result<CartViewResponse, Rejection> _buyRejection(
  BuyCartFailure failure,
  String? variantId,
) =>
    switch (failure) {
      BuyCartFailure.noRegion => const Err(
          Rejection.status(422, 'The requested selling region is unavailable'),
        ),
      BuyCartFailure.noVariant => Err(Rejection.status(
          422,
          'Variant "$variantId" is not on sale in this currency',
        )),
      BuyCartFailure.outOfStock => Err(Rejection.conflict(
          'Not enough stock for "$variantId"',
        )),
    };
