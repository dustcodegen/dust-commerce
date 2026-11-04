import 'package:commerce_server/src/features/cart/repository/repository.dart';
import 'package:dust_dart/db.dart';

/// Why a payment provider could not be retained on a cart.
enum ChoosePaymentFailure {
  /// The cart's selling region does not offer this provider.
  unsupportedProvider,
}

/// Retains the provider used by subsequent checkout and payment calls.
Future<Result<Option<ChoosePaymentFailure>, SqlxError>> choosePayment(
  CartPaymentRepository writes, {
  required String cartId,
  required String providerId,
}) async {
  if (providerId != 'manual') {
    return const Ok(Some(ChoosePaymentFailure.unsupportedProvider));
  }
  final written = await writes.setPaymentSession(cartId, providerId);
  if (written case Err(:final error)) return Err(error);
  if ((written as Ok<ExecResult, SqlxError>).value.rowsAffected == 0) {
    return const Ok(Some(ChoosePaymentFailure.unsupportedProvider));
  }
  return const Ok(None<ChoosePaymentFailure>());
}
