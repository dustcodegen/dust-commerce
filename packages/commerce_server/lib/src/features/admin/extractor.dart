import 'package:commerce_server/src/features/admin/deps.dart';
import 'package:commerce_server/src/features/admin/model.dart';
import 'package:commerce_server/src/features/admin/service/service.dart';
import 'package:dust_server/server.dart';

/// Merchant identity proven by an admin bearer token.
final class AuthenticatedAdmin {
  /// Creates the request identity.
  const AuthenticatedAdmin({required this.user, required this.token});

  /// Raw token retained only so logout can revoke its fingerprint.
  final String token;

  /// Allowlisted admin profile.
  final AdminUserResponse user;
}

/// Axum-style required authentication for the admin route tree.
final class AdminAuth implements FromRequestParts<AuthenticatedAdmin> {
  /// Creates the stateless extractor.
  const AdminAuth();

  @override
  Future<Result<AuthenticatedAdmin, Rejection>> extract(Request request) async {
    final state = await const StateExtractable<AdminDeps>().extract(request);
    if (state case Err(:final error)) return Err(error);
    final bearer = await const BearerTokenExtractable().extract(request);
    if (bearer case Err(:final error)) return Err(error);

    final deps = (state as Ok<AdminDeps, Rejection>).value;
    final token = (bearer as Ok<String, Rejection>).value;
    return switch (await authenticateAdminToken(
      deps.reads,
      token,
      deps.clock.now(),
    )) {
      Ok(value: Some(value: final user)) =>
        Ok(AuthenticatedAdmin(user: user, token: token)),
      Ok(value: None()) => const Err(Rejection.unauthorized(
          'Invalid or expired token',
          challenge: 'Bearer',
        )),
      Err() => const Err(Rejection.internal()),
    };
  }
}
