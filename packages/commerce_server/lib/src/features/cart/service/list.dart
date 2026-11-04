import 'package:commerce_server/src/features/cart/model/model.dart';
import 'package:commerce_server/src/features/cart/repository/repository.dart';
import 'package:commerce_server/src/infra/option.dart';
import 'package:dust_dart/db.dart';

/// The delivery options a cart may choose from.
///
/// Scoped to the cart's region rather than taking a region from the caller: a
/// storefront that could ask for another region's options would show prices in
/// a currency the cart cannot total.
Future<Result<Option<List<ShippingOptionResponse>>, SqlxError>>
    shippingOptionsFor(
  CartReadRepository reads,
  CartListRepository lists,
  String cartId,
) async {
  final found = await reads.findCart(cartId);
  if (found case Err(:final error)) return Err(error);
  final cartOption = optionOf((found as Ok<CartResponse?, SqlxError>).value);
  if (cartOption case None()) {
    return const Ok(None<List<ShippingOptionResponse>>());
  }
  final cart = (cartOption as Some<CartResponse>).value;

  final offered = await lists.shippingOptionsOf(cart.region.id);
  if (offered case Err(:final error)) return Err(error);

  return Ok(Some<List<ShippingOptionResponse>>(
    (offered as Ok<List<ShippingOptionResponse>, SqlxError>).value,
  ));
}
