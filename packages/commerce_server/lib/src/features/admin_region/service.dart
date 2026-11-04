import 'package:commerce_server/src/features/admin_region/model.dart';
import 'package:commerce_server/src/features/admin_region/repository.dart';
import 'package:dust_dart/db.dart';

/// Lists one bounded page of merchant-visible selling-region choices.
Future<Result<AdminRegionListResponse, SqlxError>> listAdminRegions(
  AdminRegionRepository regions, {
  required String query,
  required int limit,
  required int offset,
}) async {
  final normalized = query.trim();
  final rows = await regions.list(normalized, limit, offset);
  if (rows case Err(:final error)) return Err(error);
  final count = await regions.count(normalized);
  if (count case Err(:final error)) return Err(error);
  return Ok(AdminRegionListResponse(
    regions: (rows as Ok<List<AdminRegionResponse>, SqlxError>).value,
    count: (count as Ok<int, SqlxError>).value,
    limit: limit,
    offset: offset,
  ));
}
