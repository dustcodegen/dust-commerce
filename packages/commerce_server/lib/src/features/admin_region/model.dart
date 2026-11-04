import 'package:dust_dart/db.dart';
import 'package:dust_dart/serde.dart';

part 'model.g.dart';

/// One Admin region filter choice populated directly from its final table.
@Derive([Serialize(), FromRow()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminRegionResponse with _$AdminRegionResponse {
  /// Creates the explicit merchant allowlist.
  const AdminRegionResponse({required this.id, required this.name});

  /// Stable selling-region identifier.
  final String id;

  /// Merchant-facing selling-region name.
  final String name;
}

/// One bounded page of explicit Admin region responses.
@Derive([Serialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminRegionListResponse with _$AdminRegionListResponse {
  /// Creates list metadata and direct SQLx rows.
  const AdminRegionListResponse({
    required this.regions,
    required this.count,
    required this.limit,
    required this.offset,
  });

  /// Total active rows matching the query.
  final int count;

  /// Maximum requested page size.
  final int limit;

  /// Number of matching rows skipped.
  final int offset;

  /// Explicit merchant region rows.
  final List<AdminRegionResponse> regions;
}
