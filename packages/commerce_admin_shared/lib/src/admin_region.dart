import 'package:dust_dart/serde.dart';

part 'admin_region.g.dart';

/// One selling-region choice exposed only to the merchant Admin client.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminRegion with _$AdminRegion {
  /// Creates one explicit order-filter choice.
  const AdminRegion({required this.id, required this.name});

  /// Decodes one generated Admin API response.
  factory AdminRegion.fromJson(Map<String, Object?> json) =>
      _$AdminRegionFromJson(json);

  /// Stable identifier accepted by the order `region_id` filter.
  final String id;

  /// Merchant-facing selling-region name.
  final String name;
}

/// One bounded page of Admin region choices.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminRegionList with _$AdminRegionList {
  /// Creates generated-client paging metadata and explicit rows.
  const AdminRegionList({
    required this.regions,
    required this.count,
    required this.limit,
    required this.offset,
  });

  /// Decodes one generated Admin API response.
  factory AdminRegionList.fromJson(Map<String, Object?> json) =>
      _$AdminRegionListFromJson(json);

  /// Total active rows matching the query.
  final int count;

  /// Maximum requested page size.
  final int limit;

  /// Number of matching rows skipped.
  final int offset;

  /// Direct allowlisted region choices.
  final List<AdminRegion> regions;
}
