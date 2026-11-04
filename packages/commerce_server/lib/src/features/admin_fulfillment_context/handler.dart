import 'package:commerce_server/src/features/admin/extractor.dart';
import 'package:commerce_server/src/features/admin_fulfillment_context/deps.dart';
import 'package:commerce_server/src/features/admin_fulfillment_context/model.dart';
import 'package:commerce_server/src/features/admin_fulfillment_context/service.dart';
import 'package:commerce_server/src/http/http.dart';
import 'package:dust_server/server.dart';

/// `GET /admin/stock-locations` — lists merchant fulfillment origins.
Future<Result<AdminStockLocationListResponse, Rejection>>
    listAdminStockLocationsHandler(Request request) async {
  final actor = await const Extension<AuthenticatedAdmin>().extract(request);
  if (actor case Err(:final error)) return Err(error);
  final state = await adminFulfillmentContextDeps(request);
  if (state case Err(:final error)) return Err(error);
  final page = pagingOf(request);
  final result = await listAdminStockLocations(
    (state as Ok<AdminFulfillmentContextDeps, Rejection>).value.choices,
    query: request.requestedUri.queryParameters['q']?.trim() ?? '',
    limit: page.limit,
    offset: page.offset,
  );
  return switch (result) {
    Ok(:final value) => Ok(value),
    Err() => const Err(Rejection.internal()),
  };
}

/// `GET /admin/shipping-options` — lists compatible fulfillment methods.
Future<Result<AdminFulfillmentShippingOptionListResponse, Rejection>>
    listAdminFulfillmentShippingOptionsHandler(Request request) async {
  final actor = await const Extension<AuthenticatedAdmin>().extract(request);
  if (actor case Err(:final error)) return Err(error);
  final query = request.requestedUri.queryParameters;
  final locationId = query['stock_location_id']?.trim() ?? '';
  final regionId = query['region_id']?.trim() ?? '';
  if (locationId.isEmpty || regionId.isEmpty) {
    return const Err(Rejection.badRequest(
      'stock_location_id and region_id are required',
    ));
  }
  final state = await adminFulfillmentContextDeps(request);
  if (state case Err(:final error)) return Err(error);
  final page = pagingOf(request);
  final result = await listAdminFulfillmentShippingOptions(
    (state as Ok<AdminFulfillmentContextDeps, Rejection>).value.choices,
    stockLocationId: locationId,
    regionId: regionId,
    query: query['q']?.trim() ?? '',
    limit: page.limit,
    offset: page.offset,
  );
  return switch (result) {
    Ok(:final value) => Ok(value),
    Err() => const Err(Rejection.internal()),
  };
}
