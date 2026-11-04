import 'package:commerce_server/src/features/cart/model/region.dart';
import 'package:dust_dart/db.dart';

part 'create.g.dart';

/// The writes that start a cart.
@SqlxDao()
abstract final class CartCreateRepository {
  /// Binds the queries to [db].
  const factory CartCreateRepository(Executor db) = _$CartCreateRepository;

  /// Starts a cart in [regionId].
  @Query(r'''
INSERT INTO carts (id, region_id, customer_id, email)
VALUES ($1, $2, $3, $4)
''')
  Future<Result<ExecResult, SqlxError>> createCart(
    String id,
    String regionId,
    String? customerId,
    String? email,
  );

  /// Associates a cart with the selected selling channel.
  @Query(r'''
INSERT INTO cart_sales_channels (cart_id, sales_channel_id)
VALUES ($1, $2)
''')
  Future<Result<ExecResult, SqlxError>> linkSalesChannel(
    String cartId,
    String salesChannelId,
  );

  /// The deterministic enabled channel for the current single-store boundary.
  @Query(r'''
SELECT id
FROM sales_channels
WHERE is_disabled = 0 AND deleted_at IS NULL
ORDER BY id
LIMIT 1
''')
  Future<Result<String?, SqlxError>> firstSalesChannelId();

  /// One region by id, for a storefront that has chosen one.
  @Query(r'''
SELECT id, name, currency_code,
       tax_rate, tax_inclusive = 1 AS tax_inclusive,
       string_to_array(countries, ',') AS countries
FROM regions
WHERE id = $1
''')
  Future<Result<RegionResponse?, SqlxError>> regionById(String id);

  /// The default region, for a storefront that has not chosen one.
  @Query(r'''
SELECT id, name, currency_code,
       tax_rate, tax_inclusive = 1 AS tax_inclusive,
       string_to_array(countries, ',') AS countries
FROM regions
ORDER BY id
LIMIT 1
''')
  Future<Result<RegionResponse?, SqlxError>> firstRegion();
}
