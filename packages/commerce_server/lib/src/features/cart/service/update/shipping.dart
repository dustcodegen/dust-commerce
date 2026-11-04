import 'package:commerce_server/src/features/cart/model/model.dart';
import 'package:commerce_server/src/features/cart/repository/repository.dart';
import 'package:commerce_server/src/infra/option.dart';
import 'package:dust_dart/db.dart';

/// Why a delivery method could not be chosen.
enum ChooseShippingFailure {
  /// No cart with that id.
  noCart,

  /// The option does not exist, or belongs to another region.
  noOption,

  /// The option exists but its cart-value rules are not satisfied yet.
  notEligible,
}

/// Chooses [optionId] as the cart's delivery method.
///
/// The option is looked up scoped to the cart's own region, so one belonging
/// to another region cannot be chosen — the query refuses it rather than the
/// handler remembering to.
///
/// The price and name are snapshotted onto the cart, like a line item's price.
/// A shipping option repriced afterwards must not change what this cart was
/// quoted.
Future<Result<Option<ChooseShippingFailure>, SqlxError>> chooseShipping(
  CartReadRepository reads,
  CartListRepository lists,
  CartShippingRepository writes, {
  required String cartId,
  required String optionId,
}) async {
  final found = await reads.findCart(cartId);
  if (found case Err(:final error)) return Err(error);
  final cartOption = optionOf((found as Ok<CartResponse?, SqlxError>).value);
  if (cartOption case None()) {
    return const Ok(Some(ChooseShippingFailure.noCart));
  }
  final cart = (cartOption as Some<CartResponse>).value;

  final offered = await lists.shippingOptionFor(optionId, cart.region.id);
  if (offered case Err(:final error)) return Err(error);
  final optionValue = optionOf(
    (offered as Ok<ShippingOptionResponse?, SqlxError>).value,
  );
  if (optionValue case None()) {
    return const Ok(Some(ChooseShippingFailure.noOption));
  }
  final option = (optionValue as Some<ShippingOptionResponse>).value;
  if (!option.isAvailableFor(cart.subtotal)) {
    return const Ok(Some(ChooseShippingFailure.notEligible));
  }

  final written = await writes.setShippingMethod(
    cartId,
    option.optionId,
    option.name,
    option.amount.amount,
  );
  if (written case Err(:final error)) return Err(error);
  if ((written as Ok<ExecResult, SqlxError>).value.rowsAffected == 0) {
    return const Ok(Some(ChooseShippingFailure.notEligible));
  }

  return const Ok(None<ChooseShippingFailure>());
}
