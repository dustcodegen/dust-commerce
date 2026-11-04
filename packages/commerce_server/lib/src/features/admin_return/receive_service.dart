import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin_return/deps.dart';
import 'package:commerce_server/src/features/admin_return/model.dart';
import 'package:commerce_server/src/features/admin_return/receive_failure.dart';
import 'package:commerce_server/src/features/admin_return/receive_outcome.dart';
import 'package:commerce_server/src/features/admin_return/repository.dart';
import 'package:dust_dart/db.dart';

/// Atomically records intact and damaged units received for one return.
Future<Result<AdminReturnResponse, AdminReturnReceiveError>> receiveAdminReturn(
  AdminReturnDeps deps,
  String returnId,
  AdminReceiveReturn body,
) async {
  if (!_valid(body)) {
    return const Err(
      AdminReturnReceiveRejected(AdminReturnReceiveFailure.invalid),
    );
  }
  final persisted = await deps.serialWrite(
    () => deps.database.transaction<AdminReturnReceiveOutcome>(
      (tx) => _persist(AdminReturnRepository(tx), returnId, body),
    ),
  );
  return switch (persisted) {
    Ok(value: AdminReturnReceiveReady(:final response)) => Ok(response),
    Ok(value: AdminReturnReceiveDenied(:final failure)) =>
      Err(AdminReturnReceiveRejected(failure)),
    Err(:final error) => Err(AdminReturnReceiveStorage(error)),
  };
}

bool _valid(AdminReceiveReturn body) {
  if (body.items.isEmpty || body.items.length > 100) return false;
  final ids = <String>{};
  return body.items.every((item) =>
      ids.add(item.id) &&
      item.id.isNotEmpty &&
      item.quantity >= 0 &&
      item.damagedQuantity >= 0 &&
      item.quantity + item.damagedQuantity > 0);
}

Future<Result<AdminReturnReceiveOutcome, SqlxError>> _persist(
  AdminReturnRepository returns,
  String returnId,
  AdminReceiveReturn body,
) async {
  final active = await returns.receivable(returnId);
  if (active case Err(:final error)) return Err(error);
  if ((active as Ok<int, SqlxError>).value != 1) {
    return const Ok(
      AdminReturnReceiveDenied(AdminReturnReceiveFailure.invalid),
    );
  }
  for (final item in body.items) {
    final remaining = await returns.remaining(returnId, item.id);
    if (remaining case Err(:final error)) return Err(error);
    final available = (remaining as Ok<int?, SqlxError>).value;
    if (available == null || item.quantity + item.damagedQuantity > available) {
      return const Ok(
        AdminReturnReceiveDenied(AdminReturnReceiveFailure.invalid),
      );
    }
  }
  for (final item in body.items) {
    final updated = await returns.receiveItem(
      returnId,
      item.id,
      item.quantity,
      item.damagedQuantity,
    );
    if (updated case Err(:final error)) return Err(error);
    if ((updated as Ok<ExecResult, SqlxError>).value.rowsAffected != 1) {
      return Err(SqlxError.decode('Validated return item could not update'));
    }
    if (item.quantity > 0) {
      final restored = await returns.restoreStock(
        returnId,
        item.id,
        item.quantity,
      );
      if (restored case Err(:final error)) return Err(error);
    }
  }
  final finalized = await returns.finish(returnId, body.noNotification ? 1 : 0);
  if (finalized case Err(:final error)) return Err(error);
  if ((finalized as Ok<ExecResult, SqlxError>).value.rowsAffected != 1) {
    return const Ok(
      AdminReturnReceiveDenied(AdminReturnReceiveFailure.invalid),
    );
  }
  final refreshed = await returns.list(returnId, '', '', 1, 0);
  if (refreshed case Err(:final error)) return Err(error);
  final rows = (refreshed as Ok<List<AdminReturnResponse>, SqlxError>).value;
  return rows.length == 1
      ? Ok(AdminReturnReceiveReady(rows.single))
      : Err(SqlxError.decode('Received return could not be read'));
}
