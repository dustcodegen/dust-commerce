import 'package:commerce_server/src/features/cart/model/model.dart';
import 'package:commerce_server/src/features/cart/repository/repository.dart';
import 'package:commerce_server/src/features/cart/service/update/promotion.dart';
import 'package:commerce_server/src/features/catalog/repository/repository.dart';
import 'package:commerce_server/src/features/catalog/sellable_variant.dart';
import 'package:commerce_server/src/infra/database.dart';
import 'package:commerce_server/src/infra/option.dart';
import 'package:dust_dart/db.dart';

/// Why an existing line quantity could not be replaced.
enum UpdateLineFailure {
  /// The line does not belong to this cart.
  noLine,

  /// The line's variant is no longer available in this cart's currency.
  unavailable,

  /// Current inventory cannot cover the requested quantity.
  outOfStock,
}

/// Replaces a cart line's quantity after rechecking current inventory.
Future<Result<Option<UpdateLineFailure>, SqlxError>> updateLineQuantity(
  CommerceDatabase database, {
  required String cartId,
  required String lineId,
  required int quantity,
}) =>
    database.transaction(
      (tx) => _updateLineQuantity(
        CartReadRepository(tx),
        CartUpdateRepository(tx),
        CartShippingRepository(tx),
        CatalogReadRepository(tx),
        cartId: cartId,
        lineId: lineId,
        quantity: quantity,
      ),
    );

Future<Result<Option<UpdateLineFailure>, SqlxError>> _updateLineQuantity(
  CartReadRepository reads,
  CartUpdateRepository writes,
  CartShippingRepository shipping,
  CatalogReadRepository catalog, {
  required String cartId,
  required String lineId,
  required int quantity,
}) async {
  final foundCart = await reads.findCart(cartId);
  if (foundCart case Err(:final error)) return Err(error);
  final cartOption = optionOf(
    (foundCart as Ok<CartResponse?, SqlxError>).value,
  );
  if (cartOption case None()) {
    return const Ok(Some(UpdateLineFailure.noLine));
  }
  final cart = (cartOption as Some<CartResponse>).value;

  final foundLine = await reads.findLineById(cartId, lineId);
  if (foundLine case Err(:final error)) return Err(error);
  final lineOption = optionOf(
    (foundLine as Ok<LineItemResponse?, SqlxError>).value,
  );
  if (lineOption case None()) {
    return const Ok(Some(UpdateLineFailure.noLine));
  }
  final line = (lineOption as Some<LineItemResponse>).value;

  final priced = await catalog.findVariantForCart(
    line.variantId,
    cart.currencyCode,
    cartId,
  );
  if (priced case Err(:final error)) return Err(error);
  final variantOption = optionOf(
    (priced as Ok<SellableVariant?, SqlxError>).value,
  );
  if (variantOption case None()) {
    return const Ok(Some(UpdateLineFailure.unavailable));
  }
  final variant = (variantOption as Some<SellableVariant>).value;
  if (!variant.canFulfil(quantity)) {
    return const Ok(Some(UpdateLineFailure.outOfStock));
  }

  final written = await writes.setLineQuantity(lineId, quantity, cartId);
  if (written case Err(:final error)) return Err(error);
  if ((written as Ok<ExecResult, SqlxError>).value.rowsAffected == 0) {
    return const Ok(Some(UpdateLineFailure.noLine));
  }
  final refreshed = await refreshPromotionAmount(reads, writes, cartId);
  if (refreshed case Err(:final error)) return Err(error);
  final cleared = await shipping.clearIneligibleMethod(cartId);
  if (cleared case Err(:final error)) return Err(error);
  return const Ok(None<UpdateLineFailure>());
}
