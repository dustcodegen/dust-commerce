import 'package:commerce_server/src/features/account/crypto.dart';
import 'package:commerce_server/src/features/order_transfer/deps.dart';
import 'package:commerce_server/src/features/order_transfer/failure.dart';
import 'package:commerce_server/src/features/order_transfer/mail.dart';
import 'package:commerce_server/src/features/order_transfer/model.dart';
import 'package:commerce_server/src/features/order_transfer/outcome.dart';
import 'package:commerce_server/src/features/order_transfer/repository/repository.dart';
import 'package:commerce_server/src/infra/option.dart';
import 'package:dust_dart/db.dart';

part 'delivery.dart';

/// Creates or retries the target customer's active transfer request.
Future<Result<OrderTransferResponse, RequestOrderTransferError>>
    requestOrderTransfer(
  OrderTransferDeps deps, {
  required String orderId,
  required String customerId,
  Duration lifetime = const Duration(hours: 24),
  Duration deliveryLease = const Duration(seconds: 30),
}) async {
  if (!deps.mailer.isAvailable) {
    return const Err(RequestOrderTransferRejected(
      RequestOrderTransferFailure.deliveryUnavailable,
    ));
  }

  final now = deps.clock.now().toUtc();
  final persisted =
      await deps.database.transaction<RequestOrderTransferOutcome>((tx) async {
    final reads = OrderTransferReadRepository(tx);
    final creates = OrderTransferCreateRepository(tx);
    final updates = OrderTransferUpdateRepository(tx);
    final expired = await updates.expire(orderId, now.toIso8601String());
    if (expired case Err(:final error)) return Err(error);

    final found = await reads.candidate(orderId);
    if (found case Err(:final error)) return Err(error);
    final candidate = optionOf(
      (found as Ok<OrderTransferCandidate?, SqlxError>).value,
    );
    if (candidate case None()) {
      return const Ok(RequestOrderTransferDenied(
        RequestOrderTransferFailure.noOrder,
      ));
    }
    final order = (candidate as Some<OrderTransferCandidate>).value;
    if (order.orderStatus == 'canceled') {
      return const Ok(RequestOrderTransferDenied(
        RequestOrderTransferFailure.canceled,
      ));
    }
    if (optionOf(order.orderCustomerId) == Some(customerId)) {
      return const Ok(RequestOrderTransferDenied(
        RequestOrderTransferFailure.alreadyOwner,
      ));
    }

    final active = await reads.activeCustomer(orderId);
    if (active case Err(:final error)) return Err(error);
    final activeCustomer = optionOf((active as Ok<String?, SqlxError>).value);
    if (activeCustomer case Some(value: final id) when id != customerId) {
      return const Ok(RequestOrderTransferDenied(
        RequestOrderTransferFailure.activeForAnotherCustomer,
      ));
    }
    if (activeCustomer case Some()) {
      return _activeResponse(reads, orderId);
    }

    final token = Tokens.issue();
    final transferId = deps.clock.nextId();
    final inserted = await creates.insertTransfer(
      transferId,
      orderId,
      customerId,
      await Tokens.fingerprint(token),
      token,
      now.add(lifetime).toIso8601String(),
    );
    if (inserted case Err(:final error)) return Err(error);
    return _response(reads, transferId);
  });
  if (persisted case Err(:final error)) {
    return Err(RequestOrderTransferStorage(error));
  }
  final outcome =
      (persisted as Ok<RequestOrderTransferOutcome, SqlxError>).value;
  if (outcome case RequestOrderTransferDenied(:final failure)) {
    return Err(RequestOrderTransferRejected(failure));
  }
  final transfer = (outcome as RequestOrderTransferReady).response;

  final delivery = await _deliver(
    deps,
    transfer.id,
    now,
    deliveryLease,
  );
  if (delivery case Err(:final error)) {
    return Err(RequestOrderTransferStorage(error));
  }
  final refreshed = await deps.reads.response(transfer.id);
  if (refreshed case Err(:final error)) {
    return Err(RequestOrderTransferStorage(error));
  }
  return switch (optionOf(
    (refreshed as Ok<OrderTransferResponse?, SqlxError>).value,
  )) {
    Some(:final value) => Ok(value),
    None() => Err(RequestOrderTransferStorage(
        SqlxError.decode('Transfer disappeared after delivery'))),
  };
}

Future<Result<RequestOrderTransferOutcome, SqlxError>> _activeResponse(
  OrderTransferReadRepository reads,
  String orderId,
) async {
  final found = await reads.activeResponse(orderId);
  if (found case Err(:final error)) return Err(error);
  return switch (optionOf(
    (found as Ok<OrderTransferResponse?, SqlxError>).value,
  )) {
    Some(:final value) => Ok(RequestOrderTransferReady(value)),
    None() => Err(SqlxError.decode('Active transfer could not be read')),
  };
}

Future<Result<RequestOrderTransferOutcome, SqlxError>> _response(
  OrderTransferReadRepository reads,
  String transferId,
) async {
  final found = await reads.response(transferId);
  if (found case Err(:final error)) return Err(error);
  return switch (optionOf(
    (found as Ok<OrderTransferResponse?, SqlxError>).value,
  )) {
    Some(:final value) => Ok(RequestOrderTransferReady(value)),
    None() => Err(SqlxError.decode('Created transfer could not be read')),
  };
}
