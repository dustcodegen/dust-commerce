import 'package:commerce_server/src/features/admin_promotion/repository.dart';
import 'package:commerce_server/src/http/http.dart';
import 'package:dust_server/server.dart';

/// Dependencies for protected promotion reads.
final class AdminPromotionDeps {
  /// Creates the promotion dependency bundle.
  const AdminPromotionDeps({required this.promotions});

  /// Direct promotion list queries.
  final AdminPromotionRepository promotions;
}

/// Reads promotion dependencies from route state.
Future<Result<AdminPromotionDeps, Rejection>> adminPromotionDeps(
  Request request,
) =>
    stateOf<AdminPromotionDeps>(request);
