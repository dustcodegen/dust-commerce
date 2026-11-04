import 'package:commerce_server/src/features/region/deps.dart';
import 'package:commerce_server/src/features/region/model.dart';
import 'package:commerce_server/src/features/region/service.dart';
import 'package:dust_server/server.dart';

/// `GET /regions` — public regions used by country selectors.
Future<Result<SellingRegionListResponse, Rejection>> listRegionsHandler(
  Request request,
) async {
  final state = await regionDeps(request);
  if (state case Err(:final error)) return Err(error);
  final deps = (state as Ok<RegionDeps, Rejection>).value;
  final result = await listSellingRegions(deps.regions);
  return switch (result) {
    Ok(:final value) => Ok(value),
    Err() => const Err(Rejection.internal()),
  };
}

/// `GET /payment-providers?region_id=…` — providers configured for a region.
Future<Result<PaymentProviderListResponse, Rejection>>
    listPaymentProvidersHandler(Request request) async {
  final regionId = request.requestedUri.queryParameters['region_id']?.trim();
  if (regionId == null || regionId.isEmpty) {
    return const Err(Rejection.badRequest('region_id is required'));
  }

  final state = await regionDeps(request);
  if (state case Err(:final error)) return Err(error);
  final deps = (state as Ok<RegionDeps, Rejection>).value;
  final result = await listPaymentProviders(
    deps.regions,
    regionId: regionId,
  );
  return switch (result) {
    Ok(:final value) => Ok(value),
    Err() => const Err(Rejection.internal()),
  };
}
