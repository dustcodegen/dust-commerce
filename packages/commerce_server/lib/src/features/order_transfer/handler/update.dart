import 'package:commerce_server/src/features/order_transfer/deps.dart';
import 'package:commerce_server/src/features/order_transfer/model.dart';
import 'package:commerce_server/src/features/order_transfer/service/service.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_server/server.dart';

const ValidatedExtractable<OrderTransferDecisionBody> _decisionBody =
    ValidatedExtractable(
  JsonExtractable<OrderTransferDecisionBody>(
    OrderTransferDecisionBody.fromJson,
  ),
);

/// `POST /orders/{id}/transfer/accept` — approve with the emailed capability.
Future<Result<OrderTransferResponse, Rejection>> acceptOrderTransferHandler(
  Request request,
) =>
    _decide(request, OrderTransferDecision.accept);

/// `POST /orders/{id}/transfer/decline` — refuse with the emailed capability.
Future<Result<OrderTransferResponse, Rejection>> declineOrderTransferHandler(
  Request request,
) =>
    _decide(request, OrderTransferDecision.decline);

Future<Result<OrderTransferResponse, Rejection>> _decide(
  Request request,
  OrderTransferDecision decision,
) async {
  final orderId = pathParametersOf(request)['id'];
  if (orderId == null || orderId.isEmpty) {
    return const Err(Rejection.badRequest('An order id is required'));
  }
  final decoded = await _decisionBody.extract(request);
  if (decoded case Err(:final error)) return Err(error);
  final state = await orderTransferDeps(request);
  if (state case Err(:final error)) return Err(error);
  final deps = (state as Ok<OrderTransferDeps, Rejection>).value;
  final body = (decoded as Ok<OrderTransferDecisionBody, Rejection>).value;
  final result = await decideOrderTransfer(
    deps,
    orderId: orderId,
    token: body.token,
    decision: decision,
  );

  return switch (result) {
    Ok(:final value) => Ok(value),
    Err(
      error: DecideOrderTransferRejected(
        failure: DecideOrderTransferFailure.invalid,
      )
    ) =>
      const Err(Rejection.notFound('Order transfer')),
    Err(
      error: DecideOrderTransferRejected(
        failure: DecideOrderTransferFailure.alreadyDecided,
      )
    ) =>
      const Err(Rejection.conflict(
        'This transfer already has a different decision',
      )),
    Err(
      error: DecideOrderTransferRejected(
        failure: DecideOrderTransferFailure.orderUnavailable,
      )
    ) =>
      const Err(
          Rejection.status(422, 'The order can no longer be transferred')),
    Err(error: DecideOrderTransferStorage()) => const Err(Rejection.internal()),
  };
}
