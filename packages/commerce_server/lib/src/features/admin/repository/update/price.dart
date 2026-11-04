import 'package:commerce_server/src/features/admin/model.dart';
import 'package:dust_dart/db.dart';

part 'price.g.dart';

/// Variant-price writes kept behind the protected merchant boundary.
@SqlxDao()
abstract final class AdminVariantPriceRepository {
  /// Binds price mutations to [db].
  const factory AdminVariantPriceRepository(Executor db) =
      _$AdminVariantPriceRepository;

  /// Lists every currency backed by a selling region.
  @Query(r'''
SELECT DISTINCT currency_code
FROM regions
ORDER BY currency_code
''')
  Future<Result<List<AdminProductCurrencyResponse>, SqlxError>>
      activeCurrencies();

  /// Confirms that one active variant belongs to the requested product.
  @Query(r'''
SELECT count(*)
FROM product_variants
WHERE id = $1 AND product_id = $2 AND deleted_at IS NULL
''')
  Future<Result<int, SqlxError>> variantCount(
    String variantId,
    String productId,
  );

  /// Removes the previous price graph before its complete replacement.
  @Query(r'''
DELETE FROM variant_prices
WHERE variant_id = $1
''')
  Future<Result<ExecResult, SqlxError>> deleteAll(String variantId);

  /// Inserts one exact minor-unit amount into the replacement graph.
  @Query(r'''
INSERT INTO variant_prices (variant_id, currency_code, amount)
VALUES ($1, $2, $3)
''')
  Future<Result<ExecResult, SqlxError>> insert(
    String variantId,
    String currencyCode,
    int amount,
  );
}
