import 'package:commerce_server/src/features/account/extractor.dart';
import 'package:commerce_server/src/features/cart/deps.dart';
import 'package:commerce_server/src/features/cart/model/cart.dart';
import 'package:commerce_server/src/features/cart/repository/read/active.dart';
import 'package:commerce_server/src/features/cart/service/service.dart';
import 'package:dust_dart/db.dart';
import 'package:dust_server/server.dart';

/// A path cart proven accessible to this customer or guest request.
final class CartAccess {
  /// Creates the route-level cart capability.
  const CartAccess({required this.cart, required this.customer});

  /// The cart already loaded while enforcing access.
  final CartResponse cart;

  /// The authenticated customer, when one was supplied.
  final Option<AuthenticatedCustomer> customer;
}

/// Loads a path cart and hides customer-owned carts from every other caller.
final class CartAccessExtractor implements FromRequestParts<CartAccess> {
  /// Creates the stateless route guard.
  const CartAccessExtractor();

  @override
  Future<Result<CartAccess, Rejection>> extract(Request request) async {
    final auth = await const OptionalCustomerAuth().extract(request);
    if (auth case Err(:final error)) return Err(error);

    final id = pathParametersOf(request)['id'];
    if (id == null || id.isEmpty) {
      return const Err(Rejection.badRequest('A cart id is required'));
    }
    final state = await const StateExtractable<CartDeps>().extract(request);
    if (state case Err(:final error)) return Err(error);
    final deps = (state as Ok<CartDeps, Rejection>).value;
    final active = await CartActivityRepository(deps.database.executor).active(
      id,
    );
    if (active case Err()) return const Err(Rejection.internal());
    if ((active as Ok<int?, SqlxError>).value == null) {
      return Err(Rejection.notFound('Cart "$id"'));
    }
    final loaded = await loadCart(deps.reads, id);
    if (loaded case Err()) return const Err(Rejection.internal());

    final cartOption = (loaded as Ok<Option<CartResponse>, SqlxError>).value;
    final context = (auth as Ok<CustomerContext, Rejection>).value;
    final customer = context.authenticated;
    if (cartOption case None()) return Err(Rejection.notFound('Cart "$id"'));
    final cart = (cartOption as Some<CartResponse>).value;
    final customerId = customer.match(
      some: (actor) => actor.customer.id,
      none: () => null,
    );
    if (cart.customerId != null && cart.customerId != customerId) {
      return Err(Rejection.notFound('Cart "$id"'));
    }
    return Ok(CartAccess(cart: cart, customer: customer));
  }
}
