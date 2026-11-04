import 'package:commerce_server/src/features/cart/model/cart.dart';
import 'package:commerce_server/src/features/cart/repository/repository.dart';
import 'package:commerce_server/src/infra/option.dart';
import 'package:dust_dart/db.dart';

/// Atomically claims an active guest cart for one authenticated customer.
///
/// Returning [None] deliberately combines missing, terminal, and foreign carts
/// so the capability endpoint never confirms another customer's cart exists.
Future<Result<Option<CartResponse>, SqlxError>> transferCart(
  CartReadRepository reads,
  CartUpdateRepository writes, {
  required String cartId,
  required String customerId,
  required String email,
}) async {
  final claimed = await writes.claimCart(cartId, customerId, email);
  if (claimed case Err(:final error)) return Err(error);
  if ((claimed as Ok<ExecResult, SqlxError>).value.rowsAffected == 0) {
    return const Ok(None<CartResponse>());
  }

  final found = await reads.findCart(cartId);
  if (found case Err(:final error)) return Err(error);
  final cart = optionOf((found as Ok<CartResponse?, SqlxError>).value);
  return switch (cart) {
    Some(:final value) when value.customerId == customerId => Ok(Some(value)),
    _ => const Ok(None<CartResponse>()),
  };
}
