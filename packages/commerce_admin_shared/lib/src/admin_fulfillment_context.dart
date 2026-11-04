import 'package:dust_dart/serde.dart';

part 'admin_fulfillment_context.g.dart';

/// One active inventory origin selectable by a proven merchant.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminStockLocation with _$AdminStockLocation {
  /// Creates a location choice without exposing its private address.
  const AdminStockLocation({required this.id, required this.name});

  /// Decodes one generated Admin API response.
  factory AdminStockLocation.fromJson(Map<String, Object?> json) =>
      _$AdminStockLocationFromJson(json);

  /// Stable identifier accepted by fulfillment creation.
  final String id;

  /// Merchant-facing warehouse name.
  final String name;
}

/// One bounded page of fulfillment location choices.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminStockLocationList with _$AdminStockLocationList {
  /// Creates location rows and Medusa-compatible paging metadata.
  const AdminStockLocationList({
    required this.stockLocations,
    required this.count,
    required this.limit,
    required this.offset,
  });

  /// Decodes one generated Admin API response.
  factory AdminStockLocationList.fromJson(Map<String, Object?> json) =>
      _$AdminStockLocationListFromJson(json);

  /// Total active locations matching the query.
  final int count;

  /// Maximum requested page size.
  final int limit;

  /// Number of matching rows skipped.
  final int offset;

  /// Explicit merchant location choices.
  final List<AdminStockLocation> stockLocations;
}

/// One active shipping method selectable for an order fulfillment.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminFulfillmentShippingOption
    with _$AdminFulfillmentShippingOption {
  /// Creates a safe option projection without provider-private data.
  const AdminFulfillmentShippingOption({
    required this.id,
    required this.name,
    required this.shippingProfileId,
  });

  /// Decodes one generated Admin API response.
  factory AdminFulfillmentShippingOption.fromJson(
    Map<String, Object?> json,
  ) =>
      _$AdminFulfillmentShippingOptionFromJson(json);

  /// Stable identifier accepted by fulfillment creation.
  final String id;

  /// Merchant-facing shipping method name.
  final String name;

  /// Product profile this method can fulfill.
  final String shippingProfileId;
}

/// One bounded page of location-compatible shipping methods.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminFulfillmentShippingOptionList
    with _$AdminFulfillmentShippingOptionList {
  /// Creates shipping choices and Medusa-compatible paging metadata.
  const AdminFulfillmentShippingOptionList({
    required this.shippingOptions,
    required this.count,
    required this.limit,
    required this.offset,
  });

  /// Decodes one generated Admin API response.
  factory AdminFulfillmentShippingOptionList.fromJson(
    Map<String, Object?> json,
  ) =>
      _$AdminFulfillmentShippingOptionListFromJson(json);

  /// Total active methods matching the selected location.
  final int count;

  /// Maximum requested page size.
  final int limit;

  /// Number of matching rows skipped.
  final int offset;

  /// Explicit safe shipping-method choices.
  final List<AdminFulfillmentShippingOption> shippingOptions;
}
