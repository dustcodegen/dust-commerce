import 'package:commerce_server/src/features/admin/extractor.dart';
import 'package:commerce_server/src/features/admin_region/deps.dart';
import 'package:commerce_server/src/features/admin_region/model.dart';
import 'package:commerce_server/src/features/admin_region/service.dart';
import 'package:commerce_server/src/http/http.dart';
import 'package:dust_server/server.dart';

/// `GET /admin/regions` — lists order-filter choices for a proven merchant.
Future<Result<AdminRegionListResponse, Rejection>> listAdminRegionsHandler(
  Request request,
) async {
  final actor = await const Extension<AuthenticatedAdmin>().extract(request);
  if (actor case Err(:final error)) return Err(error);
  final state = await adminRegionDeps(request);
  if (state case Err(:final error)) return Err(error);
  final query = request.requestedUri.queryParameters;
  final limit = int.tryParse(query['limit'] ?? '') ?? defaultLimit;
  final offset = int.tryParse(query['offset'] ?? '') ?? 0;
  final deps = (state as Ok<AdminRegionDeps, Rejection>).value;
  final result = await listAdminRegions(
    deps.regions,
    query: query['q'] ?? '',
    limit: limit.clamp(1, 1000),
    offset: offset < 0 ? 0 : offset,
  );
  return switch (result) {
    Ok(:final value) => Ok(value),
    Err() => const Err(Rejection.internal()),
  };
}
