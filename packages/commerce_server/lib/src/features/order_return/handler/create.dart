import 'package:commerce_server/src/features/account/extractor.dart';
import 'package:commerce_server/src/features/order_return/deps.dart';
import 'package:commerce_server/src/features/order_return/model.dart';
import 'package:commerce_server/src/features/order_return/service/service.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_server/server.dart';

const ValidatedExtractable<OrderReturnRequestBody> _body = ValidatedExtractable(
  JsonExtractable<OrderReturnRequestBody>(OrderReturnRequestBody.fromJson),
);

/// `POST /store/returns` — request return processing for owned order items.
Future<Result<OrderReturnResponse, Rejection>> createOrderReturnHandler(
  Request request,
) async {
  final actor = await request.extract(
    const Extension<AuthenticatedCustomer>(),
  );
  final decoded = await _body.extract(request);
  if (decoded case Err(:final error)) return Err(error);
  final state = await orderReturnDeps(request);
  if (state case Err(:final error)) return Err(error);
  final deps = (state as Ok<OrderReturnDeps, Rejection>).value;
  final result = await createOrderReturn(
    deps,
    actor.customer.id,
    (decoded as Ok<OrderReturnRequestBody, Rejection>).value,
  );

  return switch (result) {
    Ok(:final value) => Ok(value),
    Err(error: OrderReturnRejected(failure: OrderReturnFailure.noOrder)) =>
      Err(Rejection.notFound('Order')),
    Err(
      error: OrderReturnRejected(
        failure: OrderReturnFailure.ineligibleOrder,
      )
    ) =>
      const Err(Rejection.status(422, 'This order is not returnable')),
    Err(error: OrderReturnRejected(failure: OrderReturnFailure.invalidItem)) =>
      const Err(Rejection.status(422, 'A return item is invalid')),
    Err(
      error: OrderReturnRejected(failure: OrderReturnFailure.invalidReason)
    ) =>
      const Err(Rejection.status(422, 'A return reason is invalid')),
    Err(
      error: OrderReturnRejected(
        failure: OrderReturnFailure.quantityUnavailable,
      )
    ) =>
      const Err(Rejection.status(422, 'Return quantity exceeds availability')),
    Err(error: OrderReturnStorage()) => const Err(Rejection.internal()),
  };
}
