import 'package:commerce_server/src/features/admin_order/complete_order_failure.dart';
import 'package:commerce_server/src/features/admin_order/complete_order_model.dart';
import 'package:commerce_server/src/features/admin_order/complete_order_repository.dart';
import 'package:commerce_server/src/features/admin_order/deps.dart';
import 'package:commerce_server/src/features/admin_order/detail_model.dart';
import 'package:commerce_server/src/features/admin_order/detail_repository.dart';
import 'package:commerce_server/src/infra/option.dart';
import 'package:dust_dart/db.dart';

/// Completes one order using Medusa's status-only lifecycle rule.
Future<Result<AdminOrderDetailResponse, AdminCompleteOrderError>>
    completeAdminOrder(AdminOrderDeps deps, String orderId) async {
  if (orderId.isEmpty || orderId.trim() != orderId) {
    return const Err(AdminCompleteOrderRejected(
      AdminCompleteOrderFailure.unavailable,
    ));
  }
  final persisted = await deps.serialWrite(
    () => deps.database.transaction<_AdminCompleteOrderOutcome>(
      (tx) => _persist(
        AdminCompleteOrderRepository(tx),
        AdminOrderDetailRepository(tx),
        orderId,
      ),
    ),
  );
  return switch (persisted) {
    Ok(value: _AdminCompleteOrderReady(:final response)) => Ok(response),
    Ok(value: _AdminCompleteOrderDenied(:final failure)) =>
      Err(AdminCompleteOrderRejected(failure)),
    Err(:final error) => Err(AdminCompleteOrderStorage(error)),
  };
}

Future<Result<_AdminCompleteOrderOutcome, SqlxError>> _persist(
  AdminCompleteOrderRepository writes,
  AdminOrderDetailRepository details,
  String orderId,
) async {
  final found = await writes.target(orderId);
  if (found case Err(:final error)) return Err(error);
  final target = optionOf(
    (found as Ok<AdminCompleteOrderTarget?, SqlxError>).value,
  );
  if (target case None()) return const Ok(_unavailable);
  if ((target as Some<AdminCompleteOrderTarget>).value.status == 'canceled') {
    return const Ok(_canceled);
  }
  final completed = await writes.complete(orderId);
  if (completed case Err(:final error)) return Err(error);
  if ((completed as Ok<ExecResult, SqlxError>).value.rowsAffected != 1) {
    return const Ok(_unavailable);
  }
  final refreshed = await details.find(orderId);
  if (refreshed case Err(:final error)) return Err(error);
  final response =
      (refreshed as Ok<AdminOrderDetailResponse?, SqlxError>).value;
  return response == null
      ? Err(SqlxError.decode('Completed order could not be read'))
      : Ok(_AdminCompleteOrderReady(response));
}

sealed class _AdminCompleteOrderOutcome {
  const _AdminCompleteOrderOutcome();
}

final class _AdminCompleteOrderReady extends _AdminCompleteOrderOutcome {
  const _AdminCompleteOrderReady(this.response);

  final AdminOrderDetailResponse response;
}

final class _AdminCompleteOrderDenied extends _AdminCompleteOrderOutcome {
  const _AdminCompleteOrderDenied(this.failure);

  final AdminCompleteOrderFailure failure;
}

const _unavailable = _AdminCompleteOrderDenied(
  AdminCompleteOrderFailure.unavailable,
);
const _canceled = _AdminCompleteOrderDenied(AdminCompleteOrderFailure.canceled);
