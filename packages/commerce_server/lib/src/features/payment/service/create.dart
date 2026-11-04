import 'package:commerce_server/src/features/checkout/repository/repository.dart';
import 'package:commerce_server/src/features/checkout/model.dart';
import 'package:commerce_server/src/features/checkout/service/service.dart';
import 'package:commerce_server/src/features/payment/repository/repository.dart';
import 'package:commerce_server/src/infra/database.dart';
import 'package:commerce_server/src/infra/option.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_dart/db.dart';

/// Why a payment could not be started.
enum AuthorizeFailure {
  /// No order with that id, or not this caller's.
  noOrder,

  /// The order was canceled, so there is nothing to pay.
  canceled,

  /// An archived order is closed to further payment activity.
  archived,
}

/// Starts a payment for [orderId], for the amount the order says.
///
/// The amount comes from the stored order total, never from the request. A
/// client that could name the amount could name a smaller one.
Future<Result<Result<OrderResponse, AuthorizeFailure>, SqlxError>>
    authorizePayment(
  CommerceDatabase database, {
  required String orderId,
  required String email,
  required Option<String> customerId,
  required String id,
  String provider = 'manual',
}) async {
  return database.transaction((tx) async {
    final orders = CheckoutReadRepository(tx);
    final reads = PaymentReadRepository(tx);
    final writes = PaymentCreateRepository(tx);
    final loaded = await loadOrder(orders, orderId);
    if (loaded case Err(:final error)) return Err(error);

    final orderOption = (loaded as Ok<Option<OrderResponse>, SqlxError>).value;
    if (orderOption case None()) {
      return const Ok(Err(AuthorizeFailure.noOrder));
    }
    final order = (orderOption as Some<OrderResponse>).value;
    final ownsOrder = switch (order.customerId) {
      null => order.email == email,
      final owner => customerId == Some(owner),
    };
    if (!ownsOrder) {
      return const Ok(Err(AuthorizeFailure.noOrder));
    }
    if (order.status == OrderStatus.canceled) {
      return const Ok(Err(AuthorizeFailure.canceled));
    }
    if (order.status == OrderStatus.archived) {
      return const Ok(Err(AuthorizeFailure.archived));
    }

    final existing = await reads.forOrder(orderId);
    if (existing case Err(:final error)) return Err(error);
    final payment = optionOf((existing as Ok<String?, SqlxError>).value);
    if (payment case Some()) return Ok(Ok(order));

    final written = await writes.authorize(
      id,
      orderId,
      provider,
      order.total.amount,
      order.total.currencyCode,
    );
    if (written case Err(:final error)) return Err(error);

    return Ok(Ok(order));
  });
}
