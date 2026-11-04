import 'package:commerce_server/src/features/account/deps.dart';
import 'package:commerce_server/src/features/account/model.dart';
import 'package:commerce_server/src/features/account/service/service.dart';
import 'package:dust_server/server.dart';

/// The customer identity proven by a bearer token.
///
/// This contains the raw token only so sign-out can revoke it. It deliberately
/// derives no serializer or string representation.
final class AuthenticatedCustomer {
  /// Creates an authenticated request identity.
  const AuthenticatedCustomer({required this.customer, required this.token});

  /// The store customer making the request.
  final CustomerResponse customer;

  /// The bearer token proven by this extraction.
  final String token;
}

/// Optional customer identity carried by guest-compatible route layers.
final class CustomerContext {
  /// Creates a request context for either a customer or a guest.
  const CustomerContext(this.authenticated);

  /// The proven customer, or [None] when no Authorization header was sent.
  final Option<AuthenticatedCustomer> authenticated;
}

/// Axum-style required authentication extracted from request parts.
final class CustomerAuth implements FromRequestParts<AuthenticatedCustomer> {
  /// Creates the stateless extractor.
  const CustomerAuth();

  @override
  Future<Result<AuthenticatedCustomer, Rejection>> extract(
    Request request,
  ) async {
    final state = await const StateExtractable<AccountDeps>().extract(request);
    if (state case Err(:final error)) return Err(error);

    final bearer = await const BearerTokenExtractable().extract(request);
    if (bearer case Err(:final error)) return Err(error);
    final token = (bearer as Ok<String, Rejection>).value;
    final deps = (state as Ok<AccountDeps, Rejection>).value;

    return switch (
        await authenticateToken(deps.reads, token, deps.clock.now())) {
      Ok(value: Some(value: final customer)) =>
        Ok(AuthenticatedCustomer(customer: customer, token: token)),
      Ok(value: None()) => const Err(Rejection.unauthorized(
          'Invalid or expired token',
          challenge: 'Bearer',
        )),
      Err() => const Err(Rejection.internal()),
    };
  }
}

/// Optional authentication where only a missing header becomes a guest.
final class OptionalCustomerAuth implements FromRequestParts<CustomerContext> {
  /// Creates the stateless extractor.
  const OptionalCustomerAuth();

  @override
  Future<Result<CustomerContext, Rejection>> extract(
    Request request,
  ) async {
    if (Authorization.of(request) == null) {
      return const Ok(CustomerContext(None<AuthenticatedCustomer>()));
    }
    return switch (await const CustomerAuth().extract(request)) {
      Ok(:final value) => Ok(CustomerContext(Some(value))),
      Err(:final error) => Err(error),
    };
  }
}
