import 'package:commerce_server/src/features/admin_order/archive_order_failure.dart';
import 'package:commerce_server/src/features/admin_order/archive_order_model.dart';
import 'package:commerce_server/src/features/admin_order/archive_order_repository.dart';
import 'package:commerce_server/src/features/admin_order/deps.dart';
import 'package:commerce_server/src/features/admin_order/detail_model.dart';
import 'package:commerce_server/src/features/admin_order/detail_repository.dart';
import 'package:commerce_server/src/infra/option.dart';
import 'package:dust_dart/db.dart';

/// Archives one completed or canceled order using Medusa's lifecycle rule.
Future<Result<AdminOrderDetailResponse, AdminArchiveOrderError>>
    archiveAdminOrder(AdminOrderDeps deps, String orderId) async {
  if (orderId.isEmpty || orderId.trim() != orderId) {
    return const Err(AdminArchiveOrderRejected(
      AdminArchiveOrderFailure.unavailable,
    ));
  }
  final persisted = await deps.serialWrite(
    () => deps.database.transaction<_AdminArchiveOrderOutcome>(
      (tx) => _persist(
        AdminArchiveOrderRepository(tx),
        AdminOrderDetailRepository(tx),
        orderId,
      ),
    ),
  );
  return switch (persisted) {
    Ok(value: _AdminArchiveOrderReady(:final response)) => Ok(response),
    Ok(value: _AdminArchiveOrderDenied(:final failure)) =>
      Err(AdminArchiveOrderRejected(failure)),
    Err(:final error) => Err(AdminArchiveOrderStorage(error)),
  };
}

Future<Result<_AdminArchiveOrderOutcome, SqlxError>> _persist(
  AdminArchiveOrderRepository writes,
  AdminOrderDetailRepository details,
  String orderId,
) async {
  final found = await writes.target(orderId);
  if (found case Err(:final error)) return Err(error);
  final target = optionOf(
    (found as Ok<AdminArchiveOrderTarget?, SqlxError>).value,
  );
  if (target case None()) return const Ok(_unavailable);
  final status = (target as Some<AdminArchiveOrderTarget>).value.status;
  if (status != 'completed' && status != 'canceled') {
    return const Ok(_ineligible);
  }
  final archived = await writes.archive(orderId);
  if (archived case Err(:final error)) return Err(error);
  if ((archived as Ok<ExecResult, SqlxError>).value.rowsAffected != 1) {
    return const Ok(_unavailable);
  }
  final refreshed = await details.find(orderId);
  if (refreshed case Err(:final error)) return Err(error);
  final response =
      (refreshed as Ok<AdminOrderDetailResponse?, SqlxError>).value;
  return response == null
      ? Err(SqlxError.decode('Archived order could not be read'))
      : Ok(_AdminArchiveOrderReady(response));
}

sealed class _AdminArchiveOrderOutcome {
  const _AdminArchiveOrderOutcome();
}

final class _AdminArchiveOrderReady extends _AdminArchiveOrderOutcome {
  const _AdminArchiveOrderReady(this.response);

  final AdminOrderDetailResponse response;
}

final class _AdminArchiveOrderDenied extends _AdminArchiveOrderOutcome {
  const _AdminArchiveOrderDenied(this.failure);

  final AdminArchiveOrderFailure failure;
}

const _unavailable = _AdminArchiveOrderDenied(
  AdminArchiveOrderFailure.unavailable,
);
const _ineligible = _AdminArchiveOrderDenied(
  AdminArchiveOrderFailure.ineligible,
);
