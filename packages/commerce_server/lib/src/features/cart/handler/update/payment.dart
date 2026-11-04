import 'package:commerce_server/src/features/cart/deps.dart';
import 'package:commerce_server/src/features/cart/extractor.dart';
import 'package:commerce_server/src/features/cart/handler/read.dart';
import 'package:commerce_server/src/features/cart/model/model.dart';
import 'package:commerce_server/src/features/cart/service/service.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_server/server.dart';

const ValidatedExtractable<ChoosePaymentBody> _body = ValidatedExtractable(
  JsonExtractable<ChoosePaymentBody>(ChoosePaymentBody.fromJson),
);

/// `POST /carts/{id}/payment-sessions` — retain the checkout provider.
Future<Result<CartViewResponse, Rejection>> choosePaymentHandler(
  Request request,
) async {
  final access = await request.extract(const Extension<CartAccess>());
  final cartId = access.cart.id;

  final decoded = await _body.extract(request);
  if (decoded case Err(:final error)) return Err(error);
  final body = (decoded as Ok<ChoosePaymentBody, Rejection>).value;

  final state = await cartDeps(request);
  if (state case Err(:final error)) return Err(error);
  final deps = (state as Ok<CartDeps, Rejection>).value;
  final result = await choosePayment(
    deps.payments,
    cartId: cartId,
    providerId: body.providerId,
  );

  return switch (result) {
    Ok(value: None()) => await cartViewOf(deps.reads, cartId),
    Ok(value: Some(value: ChoosePaymentFailure.unsupportedProvider)) => Err(
        Rejection.status(
          422,
          'Payment provider "${body.providerId}" is not offered here',
        ),
      ),
    Err() => const Err(Rejection.internal()),
  };
}
