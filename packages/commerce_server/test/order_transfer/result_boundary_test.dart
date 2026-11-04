import 'package:commerce_server/commerce_server.dart';
import 'package:test/test.dart';

import 'support.dart';

void main() {
  late TransferScenario scenario;

  tearDown(() async => scenario.stop());

  test('request service exposes one typed success or error result', () async {
    scenario = await TransferScenario.start();
    final order = await scenario.ownedOrder();

    final result = await requestOrderTransfer(
      scenario.serviceDeps(),
      orderId: order.orderId,
      customerId: order.targetId,
    );

    expect(
      result,
      isA<Ok<OrderTransferResponse, RequestOrderTransferError>>(),
    );
    final response =
        (result as Ok<OrderTransferResponse, RequestOrderTransferError>).value;
    expect(_expiresAt(response), DateTime.utc(2100, 1, 2, 12));
  });

  test('request rejection is one error value, not a nested result', () async {
    scenario = await TransferScenario.start();
    final order = await scenario.ownedOrder();

    final result = await requestOrderTransfer(
      scenario.serviceDeps(),
      orderId: order.orderId,
      customerId: order.ownerId,
    );

    expect(
      result,
      isA<Err<OrderTransferResponse, RequestOrderTransferError>>(),
    );
    expect(
      (result as Err<OrderTransferResponse, RequestOrderTransferError>).error,
      const RequestOrderTransferRejected(
        RequestOrderTransferFailure.alreadyOwner,
      ),
    );
  });

  test('decision rejection uses the same flat boundary', () async {
    scenario = await TransferScenario.start();
    final order = await scenario.ownedOrder();

    final result = await decideOrderTransfer(
      scenario.serviceDeps(),
      orderId: order.orderId,
      token: 'unknown-capability',
      decision: OrderTransferDecision.accept,
    );

    expect(
      result,
      isA<Err<OrderTransferResponse, DecideOrderTransferError>>(),
    );
    expect(
      (result as Err<OrderTransferResponse, DecideOrderTransferError>).error,
      const DecideOrderTransferRejected(
        DecideOrderTransferFailure.invalid,
      ),
    );
  });

  test('request storage failure retains the original SQLx cause', () async {
    scenario = await TransferScenario.start();
    final order = await scenario.ownedOrder();
    final deps = scenario.serviceDeps();
    await scenario.harness.database.close();

    final result = await requestOrderTransfer(
      deps,
      orderId: order.orderId,
      customerId: order.targetId,
    );

    expect(
      result,
      isA<Err<OrderTransferResponse, RequestOrderTransferError>>(),
    );
    final error =
        (result as Err<OrderTransferResponse, RequestOrderTransferError>).error;
    expect(error, isA<RequestOrderTransferStorage>());
    expect((error as RequestOrderTransferStorage).cause, isA<SqlxError>());
  });

  test('decision storage failure retains the original SQLx cause', () async {
    scenario = await TransferScenario.start();
    final order = await scenario.ownedOrder();
    final deps = scenario.serviceDeps();
    await scenario.harness.database.close();

    final result = await decideOrderTransfer(
      deps,
      orderId: order.orderId,
      token: 'unknown-capability',
      decision: OrderTransferDecision.decline,
    );

    expect(
      result,
      isA<Err<OrderTransferResponse, DecideOrderTransferError>>(),
    );
    final error =
        (result as Err<OrderTransferResponse, DecideOrderTransferError>).error;
    expect(error, isA<DecideOrderTransferStorage>());
    expect((error as DecideOrderTransferStorage).cause, isA<SqlxError>());
  });
}

DateTime _expiresAt(OrderTransferResponse response) => response.expiresAt;
