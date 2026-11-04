import 'package:commerce_server/src/features/cart/repository/repository.dart';
import 'package:commerce_server/src/features/cart/service/update/promotion.dart';
import 'package:commerce_server/src/infra/database.dart';
import 'package:dust_dart/db.dart';

/// Removes [lineId] only when it belongs to [cartId].
///
/// Returns `Ok(false)` when the scoped line does not exist.
Future<Result<bool, SqlxError>> removeLine(
  CommerceDatabase database, {
  required String cartId,
  required String lineId,
}) =>
    database.transaction((tx) async {
      final reads = CartReadRepository(tx);
      final writes = CartUpdateRepository(tx);
      final deleted = await writes.deleteLine(lineId, cartId);
      if (deleted case Err(:final error)) return Err(error);
      final found = (deleted as Ok<ExecResult, SqlxError>).value.rowsAffected;
      if (found == 0) return const Ok(false);

      final refreshed = await refreshPromotionAmount(reads, writes, cartId);
      if (refreshed case Err(:final error)) return Err(error);
      final cleared =
          await CartShippingRepository(tx).clearIneligibleMethod(cartId);
      if (cleared case Err(:final error)) return Err(error);
      return const Ok(true);
    });
