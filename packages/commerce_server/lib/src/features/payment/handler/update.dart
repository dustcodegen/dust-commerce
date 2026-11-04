import 'package:commerce_server/src/features/account/extractor.dart';
import 'package:commerce_server/src/features/checkout/handler/read.dart';
import 'package:commerce_server/src/features/checkout/model.dart';
import 'package:commerce_server/src/features/payment/deps.dart';
import 'package:commerce_server/src/features/payment/service/service.dart';
import 'package:dust_server/server.dart';

/// `POST /orders/{id}/payments/capture` — take the money.
///
/// Repeating a completed capture returns the completed order without moving
/// money again, so a timeout can be retried safely.
Future<Result<OrderResponse, Rejection>> capturePaymentHandler(
  Request request,
) async {
  final orderId = pathParametersOf(request)['id'];
  if (orderId == null || orderId.isEmpty) {
    return const Err(Rejection.badRequest('An order id is required'));
  }

  final context = await request.extract(const Extension<CustomerContext>());
  final customer = context.authenticated;
  final email = customer.match(
    some: (value) => Ok<String, Rejection>(value.customer.email),
    none: () => emailOf(request),
  );
  if (email case Err(:final error)) return Err(error);

  final state = await paymentDeps(request);
  if (state case Err(:final error)) return Err(error);
  final deps = (state as Ok<PaymentDeps, Rejection>).value;

  final result = await capturePayment(
    deps.database,
    orderId: orderId,
    email: (email as Ok<String, Rejection>).value,
    customerId: customer.map((value) => value.customer.id),
    now: deps.clock.now(),
  );

  return switch (result) {
    Ok(value: Ok(value: final order)) => Ok(order),
    Ok(value: Err(error: CaptureFailure.noOrder)) =>
      Err(Rejection.notFound('Order "$orderId"')),
    Ok(value: Err(error: CaptureFailure.noPayment)) =>
      const Err(Rejection.conflict('No payment has been started')),
    Ok(value: Err(error: CaptureFailure.canceled)) =>
      const Err(Rejection.conflict('A canceled order cannot be paid for')),
    Ok(value: Err(error: CaptureFailure.archived)) =>
      const Err(Rejection.conflict('An archived order cannot be paid for')),
    Err() => const Err(Rejection.internal()),
  };
}
