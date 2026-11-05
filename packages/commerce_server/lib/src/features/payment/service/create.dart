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

/// Error crossing the payment-authorization service boundary.
sealed class AuthorizePaymentError {
  /// Creates one authorization error.
  const AuthorizePaymentError();
}

/// A business rejection that is safe to expose to the handler.
final class AuthorizePaymentRejected extends AuthorizePaymentError {
  /// Creates one business rejection.
  const AuthorizePaymentRejected(this.failure);

  /// The stable business reason.
  final AuthorizeFailure failure;
}

/// A storage failure retained for logging without exposing SQL details.
final class AuthorizePaymentStorage extends AuthorizePaymentError {
  /// Creates one storage failure.
  const AuthorizePaymentStorage(this.cause);

  /// The original SQLx failure.
  final SqlxError cause;
}

/// Starts a payment for [orderId], for the amount the order says.
///
/// The amount comes from the stored order total, never from the request. A
/// client that could name the amount could name a smaller one.
Future<Result<OrderResponse, AuthorizePaymentError>> authorizePayment(
  CommerceDatabase database, {
  required String orderId,
  required String email,
  required Option<String> customerId,
  required String id,
  String provider = 'manual',
}) async {
  return transactionResult<OrderResponse, AuthorizePaymentError>(
    database,
    (tx) async {
      final orders = CheckoutReadRepository(tx);
      final reads = PaymentReadRepository(tx);
      final writes = PaymentCreateRepository(tx);
      final loaded = await loadOrder(orders, orderId);
      if (loaded case Err(:final error)) {
        return Err(AuthorizePaymentStorage(error));
      }

      final orderOption =
          (loaded as Ok<Option<OrderResponse>, SqlxError>).value;
      if (orderOption case None()) {
        return const Err(AuthorizePaymentRejected(AuthorizeFailure.noOrder));
      }
      final order = (orderOption as Some<OrderResponse>).value;
      final ownsOrder = switch (order.customerId) {
        null => order.email == email,
        final owner => customerId == Some(owner),
      };
      if (!ownsOrder) {
        return const Err(AuthorizePaymentRejected(AuthorizeFailure.noOrder));
      }
      if (order.status == OrderStatus.canceled) {
        return const Err(AuthorizePaymentRejected(AuthorizeFailure.canceled));
      }
      if (order.status == OrderStatus.archived) {
        return const Err(AuthorizePaymentRejected(AuthorizeFailure.archived));
      }

      final existing = await reads.forOrder(orderId);
      if (existing case Err(:final error)) {
        return Err(AuthorizePaymentStorage(error));
      }
      final payment = optionOf((existing as Ok<String?, SqlxError>).value);
      if (payment case Some()) return Ok(order);

      final written = await writes.authorize(
        id,
        orderId,
        provider,
        order.total.amount,
        order.total.currencyCode,
      );
      if (written case Err(:final error)) {
        return Err(AuthorizePaymentStorage(error));
      }

      return Ok(order);
    },
    storageError: AuthorizePaymentStorage.new,
  );
}
