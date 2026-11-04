import 'package:commerce_server/src/features/admin_order/cancel_order_failure.dart';
import 'package:commerce_server/src/features/admin_order/cancel_order_model.dart';
import 'package:commerce_server/src/features/admin_order/cancel_order_outcome.dart';
import 'package:commerce_server/src/features/admin_order/cancel_order_repository.dart';
import 'package:commerce_server/src/features/admin_order/deps.dart';
import 'package:commerce_server/src/features/admin_order/detail_model.dart';
import 'package:commerce_server/src/features/admin_order/detail_repository.dart';
import 'package:commerce_server/src/infra/option.dart';
import 'package:dust_dart/db.dart';

/// Atomically cancels one eligible order and refreshes its direct SQLx view.
Future<Result<AdminOrderDetailResponse, AdminCancelOrderError>>
    cancelAdminOrder(
  AdminOrderDeps deps,
  String orderId,
  String adminId,
) async {
  if (!_validId(orderId) || !_validId(adminId)) {
    return const Err(AdminCancelOrderRejected(
      AdminCancelOrderFailure.unavailable,
    ));
  }
  final persisted = await deps.serialWrite(
    () => deps.database.transaction<AdminCancelOrderOutcome>(
      (tx) => _persist(
        AdminCancelOrderRepository(tx),
        AdminOrderDetailRepository(tx),
        deps.nextId,
        orderId,
        adminId,
      ),
    ),
  );
  return switch (persisted) {
    Ok(value: AdminCancelOrderReady(:final response)) => Ok(response),
    Ok(value: AdminCancelOrderDenied(:final failure)) =>
      Err(AdminCancelOrderRejected(failure)),
    Err(:final error) => Err(AdminCancelOrderStorage(error)),
  };
}

bool _validId(String value) => value.isNotEmpty && value.trim() == value;

Future<Result<AdminCancelOrderOutcome, SqlxError>> _persist(
  AdminCancelOrderRepository writes,
  AdminOrderDetailRepository details,
  String Function() nextId,
  String orderId,
  String adminId,
) async {
  final found = await writes.target(orderId);
  if (found case Err(:final error)) return Err(error);
  final target = optionOf(
    (found as Ok<AdminCancelOrderTarget?, SqlxError>).value,
  );
  if (target case None()) return const Ok(_unavailable);
  final order = (target as Some<AdminCancelOrderTarget>).value;
  if (order.status == 'canceled') return const Ok(_alreadyCanceled);
  if (order.status == 'completed') return const Ok(_completed);
  if (order.activeFulfillmentCount > 0) return const Ok(_activeFulfillments);

  final paymentResult = await _cancelPayment(
    writes,
    order,
    nextId,
    adminId,
  );
  if (paymentResult case Err(:final error)) return Err(error);
  final payment = (paymentResult as Ok<_PaymentDecision, SqlxError>).value;
  if (payment case _PaymentDenied(:final failure)) {
    return Ok(AdminCancelOrderDenied(failure));
  }
  final nextPaymentStatus = (payment as _PaymentReady).status;

  final released = await writes.releaseInventory(orderId);
  if (released case Err(:final error)) return Err(error);
  final canceled =
      await writes.cancelOrder(orderId, adminId, nextPaymentStatus);
  if (canceled case Err(:final error)) return Err(error);
  if ((canceled as Ok<ExecResult, SqlxError>).value.rowsAffected != 1) {
    return const Ok(_alreadyCanceled);
  }
  final refreshed = await details.find(orderId);
  if (refreshed case Err(:final error)) return Err(error);
  final response =
      (refreshed as Ok<AdminOrderDetailResponse?, SqlxError>).value;
  return response == null
      ? Err(SqlxError.decode('Canceled order could not be read'))
      : Ok(AdminCancelOrderReady(response));
}

Future<Result<_PaymentDecision, SqlxError>> _cancelPayment(
  AdminCancelOrderRepository writes,
  AdminCancelOrderTarget order,
  String Function() nextId,
  String adminId,
) async {
  final payment = optionOf(order.paymentId);
  if (payment case None()) {
    return order.paymentStatus == 'awaiting'
        ? const Ok(_PaymentReady('awaiting'))
        : const Ok(_PaymentDenied(AdminCancelOrderFailure.invalidPayment));
  }
  if (order.paymentProvider != 'manual') {
    return const Ok(_PaymentDenied(
      AdminCancelOrderFailure.providerUnavailable,
    ));
  }
  if (order.paymentAmount == null) {
    return const Ok(_PaymentDenied(AdminCancelOrderFailure.invalidPayment));
  }
  final paymentId = (payment as Some<String>).value;
  final captured = order.paymentRecordStatus == 'captured';
  if (captured != (order.paymentStatus == 'captured') ||
      order.paymentStatus == 'refunded') {
    return const Ok(_PaymentDenied(AdminCancelOrderFailure.invalidPayment));
  }
  if (captured) {
    final refundable = order.paymentAmount! - order.refundedAmount;
    if (order.refundedAmount < 0 || refundable <= 0) {
      return const Ok(_PaymentDenied(AdminCancelOrderFailure.invalidPayment));
    }
    final refund = await writes.insertRefund(
      nextId(),
      paymentId,
      refundable,
      order.currencyCode,
      adminId,
    );
    if (refund case Err(:final error)) return Err(error);
  }
  if (order.paymentRecordStatus != 'canceled') {
    final canceled = await writes.cancelPayment(paymentId);
    if (canceled case Err(:final error)) return Err(error);
    if ((canceled as Ok<ExecResult, SqlxError>).value.rowsAffected != 1) {
      return const Ok(_PaymentDenied(AdminCancelOrderFailure.invalidPayment));
    }
  }
  return Ok(_PaymentReady(captured ? 'refunded' : 'awaiting'));
}

const _unavailable =
    AdminCancelOrderDenied(AdminCancelOrderFailure.unavailable);
const _alreadyCanceled =
    AdminCancelOrderDenied(AdminCancelOrderFailure.alreadyCanceled);
const _completed = AdminCancelOrderDenied(AdminCancelOrderFailure.completed);
const _activeFulfillments =
    AdminCancelOrderDenied(AdminCancelOrderFailure.activeFulfillments);

sealed class _PaymentDecision {
  const _PaymentDecision();
}

final class _PaymentReady extends _PaymentDecision {
  const _PaymentReady(this.status);

  final String status;
}

final class _PaymentDenied extends _PaymentDecision {
  const _PaymentDenied(this.failure);

  final AdminCancelOrderFailure failure;
}
