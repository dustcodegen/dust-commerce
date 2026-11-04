import 'package:commerce_server/src/features/cart/model/model.dart';
import 'package:commerce_server/src/features/cart/repository/repository.dart';
import 'package:commerce_server/src/features/cart/service/create.dart';
import 'package:commerce_server/src/features/cart/service/update/line.dart';
import 'package:commerce_server/src/features/catalog/repository/repository.dart';
import 'package:commerce_server/src/infra/database.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_dart/db.dart';

/// Business failures for an atomic checkout-permalink cart.
enum BuyCartFailure {
  /// No requested or default region can sell the lines.
  noRegion,

  /// A requested variant is not sellable in the selected currency/channel.
  noVariant,

  /// A requested quantity cannot be fulfilled.
  outOfStock,
}

/// Result of the atomic cart-and-lines write.
sealed class BuyCartOutcome {
  const BuyCartOutcome();
}

/// The cart was committed and can be loaded after the transaction.
final class BuyCartReady extends BuyCartOutcome {
  /// Creates a committed-cart result.
  const BuyCartReady(this.cartId);

  /// Opaque cart capability to return to the caller.
  final String cartId;
}

/// The whole operation was rejected before commit.
final class BuyCartRejected extends BuyCartOutcome {
  /// Creates a display-safe rejection.
  const BuyCartRejected(this.failure, {this.variantId});

  /// Why the permalink cannot be purchased.
  final BuyCartFailure failure;

  /// The offending public variant id, when the failure is line-specific.
  final String? variantId;
}

/// Creates a cart and all requested lines in one transaction.
Future<Result<BuyCartOutcome, SqlxError>> buyCart(
  CommerceDatabase database, {
  required String id,
  required List<AddLineBody> items,
  String? regionId,
  String? email,
  String? customerId,
  required String Function() nextId,
}) =>
    _buyCartTransaction(
      database,
      id: id,
      items: items,
      regionId: regionId,
      email: email,
      customerId: customerId,
      nextId: nextId,
    );

Future<Result<BuyCartOutcome, SqlxError>> _buyCartTransaction(
  CommerceDatabase database, {
  required String id,
  required List<AddLineBody> items,
  String? regionId,
  String? email,
  String? customerId,
  required String Function() nextId,
}) async {
  final result = await database.transaction(
    (tx) => _buyCart(
      CartCreateRepository(tx),
      CartReadRepository(tx),
      CartUpdateRepository(tx),
      CartShippingRepository(tx),
      CatalogReadRepository(tx),
      id: id,
      items: items,
      regionId: regionId,
      email: email,
      customerId: customerId,
      nextId: nextId,
    ),
  );
  if (result case Err(:final error)) {
    if (error.cause case final BuyCartRejected rejected) return Ok(rejected);
  }
  return result;
}

Future<Result<BuyCartOutcome, SqlxError>> _buyCart(
  CartCreateRepository create,
  CartReadRepository reads,
  CartUpdateRepository writes,
  CartShippingRepository shipping,
  CatalogReadRepository catalog, {
  required String id,
  required List<AddLineBody> items,
  required String Function() nextId,
  String? regionId,
  String? email,
  String? customerId,
}) async {
  final created = await createCartInTransaction(
    create,
    id: id,
    regionId: regionId,
    email: email,
    customerId: customerId,
  );
  if (created case Err(:final error)) return Err(error);
  if ((created as Ok<Option<CartResponse>, SqlxError>).value case None()) {
    return const Ok(BuyCartRejected(BuyCartFailure.noRegion));
  }

  for (final item in items) {
    final added = await addLineInTransaction(
      reads,
      writes,
      shipping,
      catalog,
      cartId: id,
      variantId: item.variantId,
      quantity: item.quantity,
      nextId: nextId,
    );
    if (added case Err(:final error)) return Err(error);
    final failure = (added as Ok<Option<AddLineFailure>, SqlxError>).value;
    switch (failure) {
      case None<AddLineFailure>():
        continue;
      case Some<AddLineFailure>(value: final reason):
        return Err(SqlxError.transaction(
          'Checkout permalink rejected before commit',
          cause: BuyCartRejected(
            reason == AddLineFailure.outOfStock
                ? BuyCartFailure.outOfStock
                : BuyCartFailure.noVariant,
            variantId: item.variantId,
          ),
        ));
    }
  }
  return Ok(BuyCartReady(id));
}
