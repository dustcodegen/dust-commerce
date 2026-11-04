import 'package:commerce_server/src/features/cart/model/cart.dart';
import 'package:commerce_server/src/features/cart/repository/repository.dart';
import 'package:commerce_server/src/infra/option.dart';
import 'package:dust_dart/db.dart';

/// The cart with [cartId], or [None] when there is none.
///
/// Two queries rather than one join. A join would repeat the cart and region
/// columns once per line, and an empty cart — which is most carts, most of the
/// time — would return no rows at all, making "no cart" and "empty cart"
/// indistinguishable.
Future<Result<Option<CartResponse>, SqlxError>> loadCart(
  CartReadRepository reads,
  String cartId,
) async {
  final found = await reads.findCart(cartId);
  if (found case Err(:final error)) return Err(error);

  return Ok(optionOf((found as Ok<CartResponse?, SqlxError>).value));
}
