part of 'create.dart';

Future<Result<bool, SqlxError>> _deliver(
  OrderTransferDeps deps,
  String transferId,
  DateTime now,
  Duration lease,
) async {
  final claimed = await deps.updates.claimDelivery(
    transferId,
    now.toIso8601String(),
    now.add(lease).toIso8601String(),
  );
  if (claimed case Err(:final error)) return Err(error);
  if ((claimed as Ok<ExecResult, SqlxError>).value.rowsAffected == 0) {
    return const Ok(false);
  }

  final found = await deps.reads.delivery(transferId);
  if (found case Err(:final error)) return Err(error);
  final delivery = optionOf(
    (found as Ok<OrderTransferDelivery?, SqlxError>).value,
  );
  if (delivery case None()) {
    return Err(SqlxError.decode('Claimed transfer delivery could not be read'));
  }
  final message = (delivery as Some<OrderTransferDelivery>).value;
  try {
    await deps.mailer.send(OrderTransferMail(
      recipient: message.recipientEmail,
      orderId: message.orderId,
      token: message.token,
      expiresAt: message.expiresAt,
    ));
  } on Object {
    final released = await deps.updates.releaseDelivery(
      transferId,
      'SMTP delivery failed',
    );
    if (released case Err(:final error)) return Err(error);
    return const Ok(false);
  }

  final delivered = await deps.updates.markDelivered(
    transferId,
    deps.clock.now().toUtc().toIso8601String(),
  );
  if (delivered case Err(:final error)) return Err(error);
  if ((delivered as Ok<ExecResult, SqlxError>).value.rowsAffected != 1) {
    return Err(SqlxError.decode('Transfer delivery lease was lost'));
  }
  return const Ok(true);
}
