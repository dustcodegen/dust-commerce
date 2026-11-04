import 'package:commerce_server/src/features/account/crypto.dart';
import 'package:commerce_server/src/features/order_transfer/deps.dart';
import 'package:commerce_server/src/features/order_transfer/failure.dart';
import 'package:commerce_server/src/features/order_transfer/model.dart';
import 'package:commerce_server/src/features/order_transfer/outcome.dart';
import 'package:commerce_server/src/features/order_transfer/repository/repository.dart';
import 'package:commerce_server/src/infra/option.dart';
import 'package:dust_dart/db.dart';

/// Owner decision made with the email capability.
enum OrderTransferDecision {
  /// Move ownership to the customer who requested the transfer.
  accept,

  /// Keep the order with its current owner.
  decline,
}

/// Accepts or declines an ownership transfer as one database transaction.
Future<Result<OrderTransferResponse, DecideOrderTransferError>>
    decideOrderTransfer(
  OrderTransferDeps deps, {
  required String orderId,
  required String token,
  required OrderTransferDecision decision,
}) async {
  final fingerprint = await Tokens.fingerprint(token);
  final now = deps.clock.now().toUtc().toIso8601String();

  final persisted = await deps.database.transaction<DecideOrderTransferOutcome>(
    (tx) async {
      final reads = OrderTransferReadRepository(tx);
      final updates = OrderTransferUpdateRepository(tx);
      final expired = await updates.expire(orderId, now);
      if (expired case Err(:final error)) return Err(error);

      final found = await reads.decision(orderId, fingerprint);
      if (found case Err(:final error)) return Err(error);
      final transfer = optionOf(
        (found as Ok<OrderTransferDecisionRow?, SqlxError>).value,
      );
      if (transfer case None()) {
        return const Ok(DecideOrderTransferDenied(
          DecideOrderTransferFailure.invalid,
        ));
      }
      final row = (transfer as Some<OrderTransferDecisionRow>).value;
      final requestedStatus = switch (decision) {
        OrderTransferDecision.accept => row.status == 'accepted',
        OrderTransferDecision.decline => row.status == 'declined',
      };
      if (requestedStatus) return _response(reads, row.id);
      if (row.status != 'requested') {
        if (row.status == 'expired') {
          return const Ok(DecideOrderTransferDenied(
            DecideOrderTransferFailure.invalid,
          ));
        }
        return const Ok(DecideOrderTransferDenied(
          DecideOrderTransferFailure.alreadyDecided,
        ));
      }

      if (decision == OrderTransferDecision.accept) {
        final moved = await updates.transferOrder(orderId, row.id);
        if (moved case Err(:final error)) return Err(error);
        if ((moved as Ok<ExecResult, SqlxError>).value.rowsAffected != 1) {
          return const Ok(DecideOrderTransferDenied(
            DecideOrderTransferFailure.orderUnavailable,
          ));
        }
        final accepted = await updates.accept(row.id, now);
        if (accepted case Err(:final error)) return Err(error);
        if ((accepted as Ok<ExecResult, SqlxError>).value.rowsAffected != 1) {
          return Err(SqlxError.decode('Transfer acceptance lost its request'));
        }
      } else {
        final declined = await updates.decline(row.id, now);
        if (declined case Err(:final error)) return Err(error);
        if ((declined as Ok<ExecResult, SqlxError>).value.rowsAffected != 1) {
          return Err(SqlxError.decode('Transfer decline lost its request'));
        }
      }
      return _response(reads, row.id);
    },
  );
  return switch (persisted) {
    Ok(value: DecideOrderTransferReady(:final response)) => Ok(response),
    Ok(value: DecideOrderTransferDenied(:final failure)) =>
      Err(DecideOrderTransferRejected(failure)),
    Err(:final error) => Err(DecideOrderTransferStorage(error)),
  };
}

Future<Result<DecideOrderTransferOutcome, SqlxError>> _response(
  OrderTransferReadRepository reads,
  String transferId,
) async {
  final found = await reads.response(transferId);
  if (found case Err(:final error)) return Err(error);
  return switch (optionOf(
    (found as Ok<OrderTransferResponse?, SqlxError>).value,
  )) {
    Some(:final value) => Ok(DecideOrderTransferReady(value)),
    None() => Err(SqlxError.decode('Decided transfer could not be read')),
  };
}
