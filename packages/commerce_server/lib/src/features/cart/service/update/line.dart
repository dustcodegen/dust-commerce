import 'package:commerce_server/src/features/cart/model/model.dart';
import 'package:commerce_server/src/features/cart/repository/repository.dart';
import 'package:commerce_server/src/features/cart/service/update/promotion.dart';
import 'package:commerce_server/src/features/catalog/repository/repository.dart';
import 'package:commerce_server/src/features/catalog/sellable_variant.dart';
import 'package:commerce_server/src/infra/database.dart';
import 'package:commerce_server/src/infra/option.dart';
import 'package:dust_dart/db.dart';

/// Why a line could not be added.
enum AddLineFailure {
  /// No cart with that id.
  noCart,

  /// The variant does not exist, or is not sold in the cart's currency.
  noVariant,

  /// The variant exists but cannot cover the quantity asked for.
  outOfStock,
}

/// Adds [quantity] of [variantId] to the cart, or says why it could not.
///
/// The price is read from the catalogue **here**, at the moment of adding, and
/// written into the line. Reading it again later would let a repricing rewrite
/// what a customer already agreed to.
///
/// Stock is checked before the write rather than trusted to a constraint,
/// because "somebody bought the last one" is an ordinary outcome of a shop and
/// deserves an answer a customer can read, not a failed insert.
///
/// Adding a variant the cart already holds raises that line's quantity instead
/// of appending a second one, keeping the earlier line's price.
Future<Result<Option<AddLineFailure>, SqlxError>> addLine(
  CommerceDatabase database, {
  required String cartId,
  required String variantId,
  required int quantity,
  required String Function() nextId,
}) =>
    database.transaction(
      (tx) => addLineInTransaction(
        CartReadRepository(tx),
        CartUpdateRepository(tx),
        CartShippingRepository(tx),
        CatalogReadRepository(tx),
        cartId: cartId,
        variantId: variantId,
        quantity: quantity,
        nextId: nextId,
      ),
    );

/// Adds one line inside an already-open cart transaction.
Future<Result<Option<AddLineFailure>, SqlxError>> addLineInTransaction(
  CartReadRepository reads,
  CartUpdateRepository writes,
  CartShippingRepository shipping,
  CatalogReadRepository catalog, {
  required String cartId,
  required String variantId,
  required int quantity,
  required String Function() nextId,
}) async {
  final found = await reads.findCart(cartId);
  if (found case Err(:final error)) return Err(error);
  final cartOption = optionOf((found as Ok<CartResponse?, SqlxError>).value);
  if (cartOption case None()) return const Ok(Some(AddLineFailure.noCart));
  final cart = (cartOption as Some<CartResponse>).value;

  final priced =
      await catalog.findVariantForCart(variantId, cart.currencyCode, cartId);
  if (priced case Err(:final error)) return Err(error);
  final variantOption = optionOf(
    (priced as Ok<SellableVariant?, SqlxError>).value,
  );
  if (variantOption case None()) {
    return const Ok(Some(AddLineFailure.noVariant));
  }
  final variant = (variantOption as Some<SellableVariant>).value;

  final existing = await reads.findLine(cartId, variantId);
  if (existing case Err(:final error)) return Err(error);
  final line = optionOf(
    (existing as Ok<LineItemResponse?, SqlxError>).value,
  );

  final wanted = line.match(
        some: (value) => value.quantity,
        none: () => 0,
      ) +
      quantity;
  if (!variant.canFulfil(wanted)) {
    return const Ok(Some(AddLineFailure.outOfStock));
  }

  final written = switch (line) {
    None() => await writes.insertLine(
        nextId(),
        cartId,
        variant.id,
        variant.productId,
        variant.productHandle,
        variant.thumbnail,
        variant.productTitle,
        variant.title,
        variant.amount,
        variant.currencyCode,
        quantity,
      ),
    Some(value: final existingLine) =>
      await writes.setLineQuantity(existingLine.id, wanted, cartId),
  };

  if (written case Err(:final error)) return Err(error);
  final refreshed = await refreshPromotionAmount(reads, writes, cartId);
  if (refreshed case Err(:final error)) return Err(error);
  final cleared = await shipping.clearIneligibleMethod(cartId);
  if (cleared case Err(:final error)) return Err(error);
  return const Ok(None<AddLineFailure>());
}
