import 'package:commerce_server/src/features/account/extractor.dart';
import 'package:commerce_server/src/features/checkout/deps.dart';
import 'package:commerce_server/src/features/checkout/failure.dart';
import 'package:commerce_server/src/features/checkout/model.dart';
import 'package:commerce_server/src/features/checkout/service/service.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_server/server.dart';

/// Decodes and validates the checkout body in one step.
///
/// JsonExtractable rejects a non-JSON content type with 415, malformed syntax
/// with 400, and a body it cannot build a CheckoutRequest from with 422 — each
/// with its own message. ValidatedExtractable then runs the generated
/// constraints, including the nested address, because the request marks it
/// `@Validate(nested: true)`.
const ValidatedExtractable<CheckoutRequest> _body = ValidatedExtractable(
  JsonExtractable<CheckoutRequest>(CheckoutRequest.fromJson),
);

/// `POST /checkout` — turn a cart into an order.
Future<Result<OrderResponse, Rejection>> placeOrderHandler(
  Request request,
) async {
  final context = await request.extract(const Extension<CustomerContext>());
  final actor = context.authenticated;
  final decoded = await _body.extract(request);
  if (decoded case Err(:final error)) return Err(error);
  final input = (decoded as Ok<CheckoutRequest, Rejection>).value;

  final state = await checkoutDeps(request);
  if (state case Err(:final error)) return Err(error);
  final deps = (state as Ok<CheckoutDeps, Rejection>).value;

  final shipping = input.shippingAddress.toAddress();
  final result = await placeOrder(
    deps.database,
    cartId: input.cartId,
    email: actor.match(
      some: (value) => value.customer.email,
      none: () => input.email,
    ),
    customerId: actor.map((value) => value.customer.id),
    shippingAddress: shipping,
    billingAddress: input.billingAddress?.toAddress() ?? shipping,
    placedAt: deps.clock.now(),
    nextId: deps.clock.nextId,
  );

  return switch (result) {
    Ok(:final value) => Ok(value),
    Err(error: CheckoutRejected(failure: CheckoutFailure.noCart)) =>
      Err(Rejection.notFound('Cart "${input.cartId}"')),
    Err(error: CheckoutRejected(failure: CheckoutFailure.emptyCart)) =>
      const Err(Rejection.status(422, 'An empty cart cannot be ordered')),
    Err(error: CheckoutRejected(failure: CheckoutFailure.outOfStock)) =>
      const Err(
        Rejection.conflict('Something in this cart sold out before checkout'),
      ),
    Err(error: CheckoutRejected(failure: CheckoutFailure.wrongCustomer)) =>
      Err(Rejection.notFound('Cart "${input.cartId}"')),
    Err(
      error: CheckoutRejected(
        failure: CheckoutFailure.countryNotInRegion,
      ),
    ) =>
      const Err(
        Rejection.status(422, 'Address country is not served by this cart'),
      ),
    Err(
      error: CheckoutRejected(
        failure: CheckoutFailure.shippingNotSelected,
      ),
    ) =>
      const Err(
        Rejection.status(422, 'Select a delivery method before checkout'),
      ),
    Err(
      error: CheckoutRejected(
        failure: CheckoutFailure.paymentNotSelected,
      ),
    ) =>
      const Err(
        Rejection.status(422, 'Select a payment method before checkout'),
      ),
    Err(error: CheckoutStorage()) => const Err(Rejection.internal()),
  };
}
