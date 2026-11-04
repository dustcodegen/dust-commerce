import 'package:commerce_server/src/features/checkout/repository/repository.dart';
import 'package:commerce_server/src/features/checkout/model.dart';
import 'package:commerce_server/src/features/checkout/service/service.dart';
import 'package:commerce_server/src/features/payment/repository/repository.dart';
import 'package:commerce_server/src/infra/database.dart';
import 'package:commerce_server/src/infra/option.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_dart/db.dart';

/// Why a payment could not be captured.
enum CaptureFailure {
  /// No order with that id, or not this caller's.
  noOrder,

  /// No payment has been started for it.
  noPayment,

  /// The order was canceled before the money moved.
  canceled,

  /// The order was archived before the money moved.
  archived,
}

/// Captures the payment on [orderId] without completing its lifecycle.
///
/// Both writes happen in one transaction: an order marked paid whose payment
/// row still says authorised, or the reverse, is a reconciliation problem
/// somebody discovers a month later.
///
/// Capture is conditional in SQL, so a second attempt affects no rows and
/// returns the already-paid order rather than moving money again.
Future<Result<Result<OrderResponse, CaptureFailure>, SqlxError>> capturePayment(
  CommerceDatabase database, {
  required String orderId,
  required String email,
  required Option<String> customerId,
  required DateTime now,
}) async {
  return database.transaction((tx) async {
    final orders = CheckoutReadRepository(tx);
    final reads = PaymentReadRepository(tx);
    final writes = PaymentUpdateRepository(tx);

    final loaded = await loadOrder(orders, orderId);
    if (loaded case Err(:final error)) return Err(error);

    final orderOption = (loaded as Ok<Option<OrderResponse>, SqlxError>).value;
    if (orderOption case None()) {
      return const Ok(Err(CaptureFailure.noOrder));
    }
    final order = (orderOption as Some<OrderResponse>).value;
    final ownsOrder = switch (order.customerId) {
      null => order.email == email,
      final owner => customerId == Some(owner),
    };
    if (!ownsOrder) {
      return const Ok(Err(CaptureFailure.noOrder));
    }
    if (order.status == OrderStatus.canceled) {
      return const Ok(Err(CaptureFailure.canceled));
    }
    if (order.status == OrderStatus.archived) {
      return const Ok(Err(CaptureFailure.archived));
    }

    final found = await reads.forOrder(orderId);
    if (found case Err(:final error)) return Err(error);
    final payment = optionOf((found as Ok<String?, SqlxError>).value);
    if (payment case None()) {
      return const Ok(Err(CaptureFailure.noPayment));
    }
    final paymentId = (payment as Some<String>).value;

    final captured = await writes.capture(
      paymentId,
      now.toUtc().toIso8601String(),
    );
    if (captured case Err(:final error)) return Err(error);
    if ((captured as Ok<ExecResult, SqlxError>).value.rowsAffected == 0) {
      return Ok(Ok(order));
    }

    final marked = await writes.markOrderCaptured(orderId);
    if (marked case Err(:final error)) return Err(error);

    // The explicit response owns its public captured transition in one place.
    return Ok(Ok(order.captured()));
  });
}
