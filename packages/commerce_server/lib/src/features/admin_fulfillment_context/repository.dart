import 'package:commerce_server/src/features/admin_fulfillment_context/model.dart';
import 'package:dust_dart/db.dart';

part 'repository.g.dart';

/// Read-only persistence for Admin fulfillment selection controls.
@SqlxDao()
abstract final class AdminFulfillmentContextRepository {
  /// Binds fulfillment choice reads to [db].
  const factory AdminFulfillmentContextRepository(Executor db) =
      _$AdminFulfillmentContextRepository;

  /// Counts active stock locations matching a merchant search.
  @Query(r'''
SELECT count(*) FROM stock_locations
WHERE deleted_at IS NULL
  AND ($1 = '' OR lower(name) LIKE '%' || lower($1) || '%')
''')
  Future<Result<int, SqlxError>> countLocations(String query);

  /// Lists safe active stock locations in stable display order.
  @Query(r'''
SELECT id, name FROM stock_locations
WHERE deleted_at IS NULL
  AND ($1 = '' OR lower(name) LIKE '%' || lower($1) || '%')
ORDER BY lower(name), id
LIMIT $2 OFFSET $3
''')
  Future<Result<List<AdminStockLocationResponse>, SqlxError>> listLocations(
    String query,
    int limit,
    int offset,
  );

  /// Counts shipping methods resolvable at one location and order region.
  @Query(r'''
SELECT count(*)
FROM shipping_options option_row
JOIN shipping_option_fulfillment_provider provider_link
  ON provider_link.shipping_option_id = option_row.id
 AND provider_link.deleted_at IS NULL
JOIN fulfillment_providers provider
  ON provider.id = provider_link.fulfillment_provider_id
 AND provider.deleted_at IS NULL
JOIN stock_location_fulfillment_providers location_link
  ON location_link.fulfillment_provider_id = provider.id
 AND location_link.stock_location_id = $1 AND location_link.deleted_at IS NULL
JOIN stock_locations location
  ON location.id = location_link.stock_location_id AND location.deleted_at IS NULL
JOIN shipping_option_shipping_profile profile_link
  ON profile_link.shipping_option_id = option_row.id
 AND profile_link.deleted_at IS NULL
JOIN shipping_profile profile
  ON profile.id = profile_link.shipping_profile_id AND profile.deleted_at IS NULL
WHERE option_row.deleted_at IS NULL AND option_row.region_id = $2
  AND ($3 = '' OR lower(option_row.name) LIKE '%' || lower($3) || '%')
''')
  Future<Result<int, SqlxError>> countOptions(
    String stockLocationId,
    String regionId,
    String query,
  );

  /// Lists only methods whose provider and profile remain usable.
  @Query(r'''
SELECT option_row.id, option_row.name,
       profile_link.shipping_profile_id
FROM shipping_options option_row
JOIN shipping_option_fulfillment_provider provider_link
  ON provider_link.shipping_option_id = option_row.id
 AND provider_link.deleted_at IS NULL
JOIN fulfillment_providers provider
  ON provider.id = provider_link.fulfillment_provider_id
 AND provider.deleted_at IS NULL
JOIN stock_location_fulfillment_providers location_link
  ON location_link.fulfillment_provider_id = provider.id
 AND location_link.stock_location_id = $1 AND location_link.deleted_at IS NULL
JOIN stock_locations location
  ON location.id = location_link.stock_location_id AND location.deleted_at IS NULL
JOIN shipping_option_shipping_profile profile_link
  ON profile_link.shipping_option_id = option_row.id
 AND profile_link.deleted_at IS NULL
JOIN shipping_profile profile
  ON profile.id = profile_link.shipping_profile_id AND profile.deleted_at IS NULL
WHERE option_row.deleted_at IS NULL AND option_row.region_id = $2
  AND ($3 = '' OR lower(option_row.name) LIKE '%' || lower($3) || '%')
ORDER BY lower(option_row.name), option_row.id
LIMIT $4 OFFSET $5
''')
  Future<Result<List<AdminFulfillmentShippingOptionResponse>, SqlxError>>
      listOptions(
    String stockLocationId,
    String regionId,
    String query,
    int limit,
    int offset,
  );
}
