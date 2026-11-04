import 'dart:convert';

import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_dart/db.dart';
import 'package:dust_dart/serde.dart';

part 'model.g.dart';

/// Explicit public selling-region response populated directly from SQLx.
@Derive([Serialize(), FromRow()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class SellingRegionResponse with _$SellingRegionResponse {
  /// Creates an explicitly allowlisted selling region.
  const SellingRegionResponse({
    required this.id,
    required this.name,
    required this.currencyCode,
    required this.taxRate,
    required this.countries,
    this.policy,
    required this.taxInclusive,
  });

  /// ISO country codes served by the region.
  @Sqlx(tryFrom: RegionCountriesFromArray())
  final List<String> countries;

  /// ISO currency code used by regional prices.
  @Sqlx(rename: 'currency_code')
  final String currencyCode;

  /// Stable region identifier.
  final String id;

  /// Customer-facing region name.
  final String name;

  /// Validated store-owned policy fields; arbitrary region metadata is hidden.
  @Sqlx(rename: 'metadata_json', tryFrom: RegionPolicyFromJson())
  final StoreRegionPolicy? policy;

  /// Whether displayed prices already contain tax.
  @Sqlx(rename: 'tax_inclusive')
  final bool taxInclusive;

  /// Tax rate in basis points.
  @Sqlx(rename: 'tax_rate')
  final int taxRate;
}

/// Explicit public region-list response.
@Derive([Serialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class SellingRegionListResponse with _$SellingRegionListResponse {
  /// Creates a complete region listing.
  const SellingRegionListResponse({required this.regions, required this.count});

  /// Number of active regions returned.
  final int count;

  /// Explicit public region allowlists.
  final List<SellingRegionResponse> regions;
}

/// Explicit public payment-provider response populated directly from SQLx.
@Derive([Serialize(), FromRow()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class PaymentProviderResponse with _$PaymentProviderResponse {
  /// Creates an allowlisted payment-provider reference.
  const PaymentProviderResponse({required this.id});

  /// Stable provider identifier accepted by payment-session selection.
  final String id;
}

/// Explicit public payment-provider list matching the Medusa store contract.
@Derive([Serialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class PaymentProviderListResponse with _$PaymentProviderListResponse {
  /// Creates a regional provider listing.
  const PaymentProviderListResponse({required this.paymentProviders});

  /// Enabled providers in stable identifier order.
  final List<PaymentProviderResponse> paymentProviders;
}

/// Converts PostgreSQL's text array into the public country list.
final class RegionCountriesFromArray
    implements SqlxTryFrom<List<String>, List<String>> {
  /// Creates the stateless converter.
  const RegionCountriesFromArray();

  @override
  List<String> decode(List<String> value) =>
      value.where((country) => country.isNotEmpty).toList(growable: false);
}

/// Decodes Medusa's policy metadata without exposing unrelated keys.
final class RegionPolicyFromJson
    implements SqlxTryFrom<StoreRegionPolicy?, String> {
  /// Creates the stateless converter.
  const RegionPolicyFromJson();

  @override
  StoreRegionPolicy? decode(String value) {
    final decoded = jsonDecode(value);
    if (decoded is! Map<String, Object?>) return null;
    return StoreRegionPolicy.fromMetadata(decoded);
  }
}
