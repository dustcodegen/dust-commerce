import 'package:dust_dart/db.dart';
import 'package:dust_dart/serde.dart';

part 'region.g.dart';

/// Explicit selling-region response.
@Derive([Serialize(), FromRow()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class RegionResponse with _$RegionResponse {
  /// Creates an allowlisted selling region.
  const RegionResponse({
    required this.id,
    required this.name,
    required this.currencyCode,
    required this.taxRate,
    required this.countries,
    required this.taxInclusive,
  });

  /// ISO country codes served by this region.
  final List<String> countries;

  /// Currency used by every regional amount.
  @Sqlx(rename: 'currency_code')
  final String currencyCode;

  /// Stable region identifier.
  final String id;

  /// Customer-facing region name.
  final String name;

  /// Whether displayed amounts already contain tax.
  @Sqlx(rename: 'tax_inclusive')
  final bool taxInclusive;

  /// Tax rate in basis points.
  @Sqlx(rename: 'tax_rate')
  final int taxRate;
}
