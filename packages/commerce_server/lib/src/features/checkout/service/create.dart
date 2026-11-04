import 'package:commerce_server/src/features/checkout/failure.dart';
import 'package:commerce_server/src/features/checkout/model.dart';
import 'package:commerce_server/src/features/checkout/service/create/outcome.dart';
import 'package:commerce_server/src/features/checkout/service/create/persist.dart';
import 'package:commerce_server/src/infra/database.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_dart/db.dart';

/// Atomically turns one cart into an order through a flat error boundary.
Future<Result<OrderResponse, CheckoutError>> placeOrder(
  CommerceDatabase database, {
  required String cartId,
  required String email,
  required Option<String> customerId,
  required Address shippingAddress,
  required Address billingAddress,
  required DateTime placedAt,
  required String Function() nextId,
}) async {
  final persisted = await database.transaction<CheckoutPlacementOutcome>(
    (tx) => persistOrder(
      tx,
      cartId: cartId,
      email: email,
      customerId: customerId,
      shippingAddress: shippingAddress,
      billingAddress: billingAddress,
      placedAt: placedAt,
      nextId: nextId,
    ),
  );
  return switch (persisted) {
    Ok(value: CheckoutPlacementReady(:final order)) => Ok(order),
    Ok(value: CheckoutPlacementDenied(:final failure)) =>
      Err(CheckoutRejected(failure)),
    Err(:final error) => Err(CheckoutStorage(error)),
  };
}
