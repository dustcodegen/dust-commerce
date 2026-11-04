import 'package:commerce_server/src/features/checkout/repository/repository.dart';
import 'package:commerce_server/src/http/http.dart';
import 'package:commerce_server/src/infra/database.dart';
import 'package:dust_server/server.dart';

/// Everything the checkout handlers need, attached once with `withState`.
final class CheckoutDeps {
  /// Creates a [CheckoutDeps].
  const CheckoutDeps({
    required this.database,
    required this.reads,
    required this.customerReads,
    required this.lists,
    required this.clock,
  });

  /// The clock and the identifier source.
  final Clock clock;

  /// The database, for the placing transaction.
  final CommerceDatabase database;

  /// Loading an order through its proven customer owner.
  final CheckoutCustomerReadRepository customerReads;

  /// Listing somebody's orders.
  final CheckoutListRepository lists;

  /// Loading one.
  final CheckoutReadRepository reads;
}

/// The checkout dependencies, or the 500 that says they were never attached.
Future<Result<CheckoutDeps, Rejection>> checkoutDeps(Request request) =>
    stateOf<CheckoutDeps>(request);
