import 'package:commerce_server/src/features/region/model.dart';
import 'package:dust_dart/db.dart';

part 'repository.g.dart';

/// Public selling-region queries.
@SqlxDao()
abstract final class SellingRegionRepository {
  /// Binds the queries to [db].
  const factory SellingRegionRepository(Executor db) =
      _$SellingRegionRepository;

  /// Lists active regions in stable display order.
  @Query(r'''
SELECT id, name, currency_code, tax_rate,
       tax_inclusive <> 0 AS tax_inclusive,
       string_to_array(countries, ',') AS countries
FROM regions
WHERE deleted_at IS NULL
ORDER BY name, id
''')
  Future<Result<List<SellingRegionResponse>, SqlxError>> list();

  /// Lists enabled payment providers for one active selling region.
  @Query(r'''
SELECT region_payment_providers.provider_id AS id
FROM region_payment_providers
JOIN regions ON regions.id = region_payment_providers.region_id
WHERE region_payment_providers.region_id = $1
  AND region_payment_providers.enabled = 1
  AND region_payment_providers.provider_id = 'manual'
  AND regions.deleted_at IS NULL
ORDER BY region_payment_providers.provider_id
''')
  Future<Result<List<PaymentProviderResponse>, SqlxError>> paymentProviders(
    String regionId,
  );
}
