import 'package:commerce_server/src/features/cart/repository/repository.dart';
import 'package:commerce_server/src/features/catalog/repository/repository.dart';
import 'package:commerce_server/src/http/http.dart';
import 'package:commerce_server/src/infra/database.dart';
import 'package:dust_server/server.dart';

/// Everything the cart handlers need, attached once with `withState`.
final class CartDeps {
  /// Creates a [CartDeps].
  const CartDeps({
    required this.reads,
    required this.lists,
    required this.writes,
    required this.catalog,
    required this.clock,
    required this.database,
    required this.shipping,
    required this.payments,
  });

  /// Finding a variant to add.
  final CatalogReadRepository catalog;

  /// The clock and the identifier source.
  final Clock clock;

  /// Database owner used for atomic cart mutations.
  final CommerceDatabase database;

  /// What a region offers.
  final CartListRepository lists;

  /// Checkout payment-provider writes.
  final CartPaymentRepository payments;

  /// Loading a cart and its lines.
  final CartReadRepository reads;

  /// Delivery-method writes and eligibility enforcement.
  final CartShippingRepository shipping;

  /// Changing what it holds.
  final CartUpdateRepository writes;
}

/// The cart dependencies, or the 500 that says they were never attached.
Future<Result<CartDeps, Rejection>> cartDeps(Request request) =>
    stateOf<CartDeps>(request);
