import 'package:dust_dart/serde.dart';

part 'admin_variant_price.g.dart';

/// One exact regional amount returned only to the merchant Admin client.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminProductVariantPrice with _$AdminProductVariantPrice {
  /// Creates an explicitly allowlisted variant price response.
  const AdminProductVariantPrice({
    required this.currencyCode,
    required this.amount,
  });

  /// Decodes the generated Admin response.
  factory AdminProductVariantPrice.fromJson(Map<String, Object?> json) =>
      _$AdminProductVariantPriceFromJson(json);

  /// Integer amount in the currency's minor unit.
  final int amount;

  /// Lowercase ISO 4217 currency backed by an active selling region.
  final String currencyCode;
}

/// One exact replacement amount accepted from a proven merchant.
@Derive([ToString(), Eq(), Validate(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminUpdateVariantPrice with _$AdminUpdateVariantPrice {
  /// Creates one validated price mutation.
  const AdminUpdateVariantPrice({
    required this.currencyCode,
    required this.amount,
  });

  /// Decodes the generated Admin request.
  factory AdminUpdateVariantPrice.fromJson(Map<String, Object?> json) =>
      _$AdminUpdateVariantPriceFromJson(json);

  /// Integer amount in the currency's minor unit.
  @Validate(range: Range(min: 0), message: 'Enter a non-negative price')
  final int amount;

  /// Lowercase ISO 4217 currency backed by an active selling region.
  @Validate(length: Length(min: 3, max: 3), message: 'Choose a currency')
  @Validate(regex: r'^[a-z]{3}$', message: 'Choose a currency')
  final String currencyCode;
}

/// Complete active-currency replacement for one product variant.
@Derive([ToString(), Eq(), Validate(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminUpdateVariantPrices with _$AdminUpdateVariantPrices {
  /// Creates a complete price replacement.
  const AdminUpdateVariantPrices({required this.prices});

  /// Decodes the generated Admin request.
  factory AdminUpdateVariantPrices.fromJson(Map<String, Object?> json) =>
      _$AdminUpdateVariantPricesFromJson(json);

  /// Exactly one non-negative amount for every active currency.
  final List<AdminUpdateVariantPrice> prices;
}
