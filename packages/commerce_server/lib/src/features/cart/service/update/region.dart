import 'package:commerce_server/src/features/cart/model/model.dart';
import 'package:commerce_server/src/features/cart/repository/repository.dart';
import 'package:commerce_server/src/features/cart/service/update/promotion.dart';
import 'package:commerce_server/src/infra/database.dart';
import 'package:commerce_server/src/infra/option.dart';
import 'package:dust_dart/db.dart';

/// Why a cart could not move to a selling region.
enum UpdateCartRegionFailure {
  /// The active cart disappeared before the update began.
  noCart,

  /// The requested region does not exist.
  noRegion,

  /// At least one cart variant has no price in the target currency.
  unavailableLines,
}

/// Reprices and reconciles a cart under one database transaction.
Future<Result<Option<UpdateCartRegionFailure>, SqlxError>> updateCartRegion(
  CommerceDatabase database, {
  required String cartId,
  required String regionId,
  required DateTime now,
}) =>
    database.transaction((tx) async {
      final creates = CartCreateRepository(tx);
      final reads = CartReadRepository(tx);
      final writes = CartUpdateRepository(tx);
      final shipping = CartShippingRepository(tx);

      final foundCart = await reads.findCart(cartId);
      if (foundCart case Err(:final error)) return Err(error);
      final cart = optionOf(
        (foundCart as Ok<CartResponse?, SqlxError>).value,
      );
      if (cart case None()) {
        return const Ok(Some(UpdateCartRegionFailure.noCart));
      }
      final current = (cart as Some<CartResponse>).value;

      final foundRegion = await creates.regionById(regionId);
      if (foundRegion case Err(:final error)) return Err(error);
      final region = optionOf(
        (foundRegion as Ok<RegionResponse?, SqlxError>).value,
      );
      if (region case None()) {
        return const Ok(Some(UpdateCartRegionFailure.noRegion));
      }
      final target = (region as Some<RegionResponse>).value;
      if (current.region.id == target.id) return const Ok(None());

      final unavailable = await writes.countLinesWithoutPrice(
        cartId,
        target.currencyCode,
      );
      if (unavailable case Err(:final error)) return Err(error);
      if ((unavailable as Ok<int, SqlxError>).value > 0) {
        return const Ok(Some(UpdateCartRegionFailure.unavailableLines));
      }

      final repriced = await writes.repriceLines(cartId, target.currencyCode);
      if (repriced case Err(:final error)) return Err(error);
      final changed = await writes.setRegion(cartId, target.id);
      if (changed case Err(:final error)) return Err(error);
      if ((changed as Ok<ExecResult, SqlxError>).value.rowsAffected == 0) {
        return const Ok(Some(UpdateCartRegionFailure.noCart));
      }
      final clearedShipping = await shipping.clearShippingMethod(cartId);
      if (clearedShipping case Err(:final error)) return Err(error);

      final applied = optionOf(current.promotions.firstOrNull);
      if (applied case Some(value: final promotion)) {
        final reapplied = await applyPromotion(
          reads,
          writes,
          cartId: cartId,
          code: promotion.code,
          now: now,
        );
        if (reapplied case Err(:final error)) return Err(error);
        if ((reapplied as Ok<Option<ApplyPromotionFailure>, SqlxError>).value
            case Some()) {
          final cleared = await writes.clearPromotion(cartId);
          if (cleared case Err(:final error)) return Err(error);
        }
      }

      return const Ok(None());
    });
