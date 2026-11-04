import 'package:commerce_server/src/features/cart/model/model.dart';
import 'package:commerce_server/src/features/cart/repository/repository.dart';
import 'package:commerce_server/src/features/cart/service/read.dart';
import 'package:commerce_server/src/infra/option.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_dart/db.dart';

/// Why a promotion could not be applied.
enum ApplyPromotionFailure {
  /// No cart with that id.
  noCart,

  /// No promotion with that code.
  noPromotion,

  /// The code exists but is outside its window or out of redemptions.
  notUsable,

  /// The code is a fixed amount in a currency this cart does not use.
  wrongCurrency,
}

/// Applies [code] to the cart, working out what it takes off.
///
/// The amount is computed here and stored, rather than recomputed whenever the
/// cart is read. A percentage of a subtotal that later changes should change
/// with it — so this is recomputed on every line change by the caller — but
/// what a cart was last told it saves must not silently drift between two
/// reads of the same unchanged cart.
Future<Result<Option<ApplyPromotionFailure>, SqlxError>> applyPromotion(
  CartReadRepository reads,
  CartUpdateRepository writes, {
  required String cartId,
  required String code,
  required DateTime now,
}) async {
  final loaded = await loadCart(reads, cartId);
  if (loaded case Err(:final error)) return Err(error);
  final cartOption = (loaded as Ok<Option<CartResponse>, SqlxError>).value;
  if (cartOption case None()) {
    return const Ok(Some(ApplyPromotionFailure.noCart));
  }
  final cart = (cartOption as Some<CartResponse>).value;

  final found = await reads.promotionByCode(code);
  if (found case Err(:final error)) return Err(error);
  final promotionOption = optionOf(
    (found as Ok<PromotionPolicy?, SqlxError>).value,
  );
  if (promotionOption case None()) {
    return const Ok(Some(ApplyPromotionFailure.noPromotion));
  }
  final promotion = (promotionOption as Some<PromotionPolicy>).value;
  if (!promotion.isUsableAt(now)) {
    return const Ok(Some(ApplyPromotionFailure.notUsable));
  }
  if (promotion.type == PromotionType.fixed &&
      promotion.currencyCode != cart.region.currencyCode) {
    return const Ok(Some(ApplyPromotionFailure.wrongCurrency));
  }

  final off = promotion.discountOn(cart.subtotal);
  final written = await writes.setPromotion(
    cartId,
    promotion.id,
    promotion.code,
    promotion.type.name,
    promotion.promotionValue,
    promotion.currencyCode,
    off.amount,
  );
  if (written case Err(:final error)) return Err(error);

  return const Ok(None<ApplyPromotionFailure>());
}

/// Recalculates the applied snapshot after a line mutation.
Future<Result<Unit, SqlxError>> refreshPromotionAmount(
  CartReadRepository reads,
  CartUpdateRepository writes,
  String cartId,
) async {
  final found = await reads.promotionOn(cartId);
  if (found case Err(:final error)) return Err(error);
  final promotion = optionOf(
    (found as Ok<AppliedPromotionResponse?, SqlxError>).value,
  );
  if (promotion case None()) return const Ok(unit);

  final loaded = await reads.findCart(cartId);
  if (loaded case Err(:final error)) return Err(error);
  final cart = optionOf((loaded as Ok<CartResponse?, SqlxError>).value);
  if (cart case None()) return const Ok(unit);

  final applied = (promotion as Some<AppliedPromotionResponse>).value;
  final subtotal = (cart as Some<CartResponse>).value.subtotal;
  final updated = await writes.updatePromotionAmount(
    cartId,
    applied.discountOn(subtotal).amount,
  );
  if (updated case Err(:final error)) return Err(error);
  return const Ok(unit);
}

/// Removes whatever promotion the cart had.
///
/// Removing a code the cart does not have is not an error. The customer wanted
/// no discount applied, and that is the state they end in either way.
Future<Result<bool, SqlxError>> removePromotion(
  CartReadRepository reads,
  CartUpdateRepository writes,
  String cartId,
) async {
  final found = await reads.findCart(cartId);
  if (found case Err(:final error)) return Err(error);
  final cart = optionOf((found as Ok<CartResponse?, SqlxError>).value);
  if (cart case None()) {
    return const Ok(false);
  }

  final cleared = await writes.clearPromotion(cartId);
  if (cleared case Err(:final error)) return Err(error);
  return const Ok(true);
}
