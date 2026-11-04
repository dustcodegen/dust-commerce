import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin_order/deps.dart';
import 'package:commerce_server/src/features/admin_refund/failure.dart';
import 'package:commerce_server/src/features/admin_refund/outcome.dart';
import 'package:commerce_server/src/features/admin_refund/payment_model.dart';
import 'package:commerce_server/src/features/admin_refund/payment_repository.dart';
import 'package:commerce_server/src/infra/option.dart';
import 'package:dust_dart/db.dart';

/// Atomically refunds one captured payment and returns its refreshed response.
Future<Result<AdminRefundedPaymentResponse, AdminPaymentRefundError>>
    refundAdminPayment(
  AdminOrderDeps deps,
  String paymentId,
  String adminId,
  AdminRefundPayment body,
) async {
  if (!_validId(paymentId) || !_validId(adminId)) {
    return const Err(AdminPaymentRefundRejected(
      AdminPaymentRefundFailure.unavailable,
    ));
  }
  final persisted = await deps.serialWrite(
    () => deps.database.transaction<AdminPaymentRefundOutcome>(
      (tx) => _persist(
        AdminPaymentRefundRepository(tx),
        deps.nextId,
        paymentId,
        adminId,
        body,
      ),
    ),
  );
  return switch (persisted) {
    Ok(value: AdminPaymentRefundReady(:final response)) => Ok(response),
    Ok(value: AdminPaymentRefundDenied(:final failure)) =>
      Err(AdminPaymentRefundRejected(failure)),
    Err(:final error) => Err(AdminPaymentRefundStorage(error)),
  };
}

bool _validId(String value) => value.isNotEmpty && value.trim() == value;

Future<Result<AdminPaymentRefundOutcome, SqlxError>> _persist(
  AdminPaymentRefundRepository payments,
  String Function() nextId,
  String paymentId,
  String adminId,
  AdminRefundPayment body,
) async {
  final found = await payments.target(paymentId);
  if (found case Err(:final error)) return Err(error);
  final target = optionOf(
    (found as Ok<AdminPaymentRefundTarget?, SqlxError>).value,
  );
  if (target case None()) return const Ok(_unavailable);
  final payment = (target as Some<AdminPaymentRefundTarget>).value;
  if (payment.providerId != 'manual') return const Ok(_providerUnavailable);
  if (payment.paymentRecordStatus != 'captured' || payment.capturedAt == null) {
    return const Ok(_notCaptured);
  }
  if (payment.orderPaymentStatus != 'captured' ||
      payment.refundedAmount < 0 ||
      payment.refundedAmount >= payment.amount) {
    return const Ok(_invalidPayment);
  }
  final remaining = payment.amount - payment.refundedAmount;
  final requested = switch (body.amount) {
    Some(:final value) => value,
    None() => remaining,
  };
  if (requested <= 0 || requested > remaining) {
    return const Ok(_invalidAmount);
  }
  final reasonId = switch (body.refundReasonId) {
    Some(:final value) => value,
    None() => null,
  };
  if (reasonId != null) {
    if (!_validId(reasonId)) return const Ok(_unavailableReason);
    final count = await payments.activeReasonCount(reasonId);
    if (count case Err(:final error)) return Err(error);
    if ((count as Ok<int, SqlxError>).value != 1) {
      return const Ok(_unavailableReason);
    }
  }
  final note = switch (body.note) {
    Some(:final value) => value,
    None() => null,
  };
  if (note != null &&
      (note.isEmpty || note.length > 1000 || note.trim() != note)) {
    return const Ok(_invalidPayment);
  }
  final inserted = await payments.insert(
    nextId(),
    paymentId,
    requested,
    payment.currencyCode,
    reasonId,
    note,
    adminId,
  );
  if (inserted case Err(:final error)) return Err(error);
  if (requested == remaining) {
    final updated = await payments.markOrderRefunded(payment.orderId);
    if (updated case Err(:final error)) return Err(error);
    if ((updated as Ok<ExecResult, SqlxError>).value.rowsAffected != 1) {
      return Err(SqlxError.decode('Refunded order could not be updated'));
    }
  }
  final refreshed = await payments.find(paymentId);
  if (refreshed case Err(:final error)) return Err(error);
  final response =
      (refreshed as Ok<AdminRefundedPaymentResponse?, SqlxError>).value;
  return response == null
      ? Err(SqlxError.decode('Refunded payment could not be read'))
      : Ok(AdminPaymentRefundReady(response));
}

const _unavailable =
    AdminPaymentRefundDenied(AdminPaymentRefundFailure.unavailable);
const _invalidPayment =
    AdminPaymentRefundDenied(AdminPaymentRefundFailure.invalidPayment);
const _notCaptured =
    AdminPaymentRefundDenied(AdminPaymentRefundFailure.notCaptured);
const _invalidAmount =
    AdminPaymentRefundDenied(AdminPaymentRefundFailure.invalidAmount);
const _unavailableReason =
    AdminPaymentRefundDenied(AdminPaymentRefundFailure.unavailableReason);
const _providerUnavailable =
    AdminPaymentRefundDenied(AdminPaymentRefundFailure.providerUnavailable);
