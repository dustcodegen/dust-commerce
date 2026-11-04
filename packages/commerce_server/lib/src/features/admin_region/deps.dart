import 'package:commerce_server/src/features/admin_region/repository.dart';
import 'package:commerce_server/src/http/http.dart';
import 'package:dust_server/server.dart';

/// Persistence required only by merchant region routes.
final class AdminRegionDeps {
  /// Creates the focused region dependency bundle.
  const AdminRegionDeps({required this.regions});

  /// Protected region discovery reads.
  final AdminRegionRepository regions;
}

/// Extracts attached region dependencies or returns a configuration failure.
Future<Result<AdminRegionDeps, Rejection>> adminRegionDeps(Request request) =>
    stateOf<AdminRegionDeps>(request);
