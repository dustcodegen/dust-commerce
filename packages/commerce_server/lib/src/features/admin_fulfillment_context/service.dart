import 'package:commerce_server/src/features/admin_fulfillment_context/model.dart';
import 'package:commerce_server/src/features/admin_fulfillment_context/repository.dart';
import 'package:dust_dart/db.dart';

/// Lists one bounded page of safe fulfillment origins.
Future<Result<AdminStockLocationListResponse, SqlxError>>
    listAdminStockLocations(
  AdminFulfillmentContextRepository repository, {
  required String query,
  required int limit,
  required int offset,
}) async {
  final count = await repository.countLocations(query);
  if (count case Err(:final error)) return Err(error);
  final rows = await repository.listLocations(query, limit, offset);
  return switch (rows) {
    Ok(:final value) => Ok(AdminStockLocationListResponse(
        stockLocations: value,
        count: (count as Ok<int, SqlxError>).value,
        limit: limit,
        offset: offset,
      )),
    Err(:final error) => Err(error),
  };
}

/// Lists methods compatible with one inventory origin and selling region.
Future<Result<AdminFulfillmentShippingOptionListResponse, SqlxError>>
    listAdminFulfillmentShippingOptions(
  AdminFulfillmentContextRepository repository, {
  required String stockLocationId,
  required String regionId,
  required String query,
  required int limit,
  required int offset,
}) async {
  final count = await repository.countOptions(
    stockLocationId,
    regionId,
    query,
  );
  if (count case Err(:final error)) return Err(error);
  final rows = await repository.listOptions(
    stockLocationId,
    regionId,
    query,
    limit,
    offset,
  );
  return switch (rows) {
    Ok(:final value) => Ok(AdminFulfillmentShippingOptionListResponse(
        shippingOptions: value,
        count: (count as Ok<int, SqlxError>).value,
        limit: limit,
        offset: offset,
      )),
    Err(:final error) => Err(error),
  };
}
