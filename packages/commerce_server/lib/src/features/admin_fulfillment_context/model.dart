import 'package:dust_dart/db.dart';
import 'package:dust_dart/serde.dart';

part 'model.g.dart';

/// Safe stock-location choice populated directly from its final table.
@Derive([Serialize(), FromRow()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminStockLocationResponse with _$AdminStockLocationResponse {
  /// Creates one explicit merchant location projection.
  const AdminStockLocationResponse({
    required this.id,
    required this.name,
    this.address1,
    this.city,
    this.province,
    this.postalCode,
    this.countryCode,
  });

  /// Stable identifier accepted by fulfillment creation.
  final String id;

  /// Merchant-facing warehouse name.
  final String name;

  /// First address line, when the location has a physical address.
  @Sqlx(rename: 'address_1')
  @SerDe(rename: 'address_1')
  final String? address1;

  /// City shown in the location list when available.
  final String? city;

  /// Administrative area shown in the location list when available.
  final String? province;

  /// Postal code shown in the location list when available.
  @Sqlx(rename: 'postal_code')
  final String? postalCode;

  /// Lowercase ISO country code shown in the location list when available.
  @Sqlx(rename: 'country_code')
  final String? countryCode;
}

/// One bounded page of direct stock-location projections.
@Derive([Serialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminStockLocationListResponse
    with _$AdminStockLocationListResponse {
  /// Creates rows and Medusa-compatible paging metadata.
  const AdminStockLocationListResponse({
    required this.stockLocations,
    required this.count,
    required this.limit,
    required this.offset,
  });

  /// Total active locations matching the query.
  final int count;

  /// Maximum requested page size.
  final int limit;

  /// Number of matching rows skipped.
  final int offset;

  /// Explicit merchant location choices.
  final List<AdminStockLocationResponse> stockLocations;
}

/// Safe fulfillment method populated directly from final relation tables.
@Derive([Serialize(), FromRow()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminFulfillmentShippingOptionResponse
    with _$AdminFulfillmentShippingOptionResponse {
  /// Creates one option without exposing provider-private configuration.
  const AdminFulfillmentShippingOptionResponse({
    required this.id,
    required this.name,
    required this.shippingProfileId,
  });

  /// Stable identifier accepted by fulfillment creation.
  final String id;

  /// Merchant-facing shipping method name.
  final String name;

  /// Product profile this method can fulfill.
  @Sqlx(rename: 'shipping_profile_id')
  final String shippingProfileId;
}

/// One bounded page of location-compatible shipping methods.
@Derive([Serialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminFulfillmentShippingOptionListResponse
    with _$AdminFulfillmentShippingOptionListResponse {
  /// Creates rows and Medusa-compatible paging metadata.
  const AdminFulfillmentShippingOptionListResponse({
    required this.shippingOptions,
    required this.count,
    required this.limit,
    required this.offset,
  });

  /// Total compatible active shipping methods.
  final int count;

  /// Maximum requested page size.
  final int limit;

  /// Number of matching rows skipped.
  final int offset;

  /// Explicit safe shipping-method choices.
  final List<AdminFulfillmentShippingOptionResponse> shippingOptions;
}
