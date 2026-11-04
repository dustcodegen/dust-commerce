import 'package:commerce_server/src/features/region/repository.dart';
import 'package:commerce_server/src/http/http.dart';
import 'package:dust_server/server.dart';

/// Dependencies for public selling-region discovery.
final class RegionDeps {
  /// Creates region dependencies.
  const RegionDeps({required this.regions});

  /// Active region listing queries.
  final SellingRegionRepository regions;
}

/// Region dependencies attached by the application composition root.
Future<Result<RegionDeps, Rejection>> regionDeps(Request request) =>
    stateOf<RegionDeps>(request);
