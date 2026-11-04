import 'package:commerce_server/src/http/http.dart';
import 'package:commerce_server/src/infra/database.dart';
import 'package:dust_server/server.dart';

/// Everything the payment handlers need, attached once with `withState`.
///
/// One object rather than four separate pieces of state. A handler that reads
/// four does four lookups and four unwraps before it does any work, and the
/// unwrapping is noise where the point of the function should be.
///
/// This is the seam a generated `@State()` parameter would occupy. Written by
/// hand it is a small price for handlers that stay plain functions, nameable
/// at the route as `post(authorizePaymentHandler)` — which is how dust_server's
/// own examples read.
final class PaymentDeps {
  /// Creates a [PaymentDeps].
  const PaymentDeps({
    required this.database,
    required this.clock,
  });

  /// The clock and the identifier source.
  final Clock clock;

  /// The database, for the capture transaction.
  final CommerceDatabase database;
}

/// The payment dependencies, or the 500 that says they were never attached.
Future<Result<PaymentDeps, Rejection>> paymentDeps(Request request) =>
    stateOf<PaymentDeps>(request);
