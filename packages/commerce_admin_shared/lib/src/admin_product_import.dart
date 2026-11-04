import 'package:dust_dart/serde.dart';

part 'admin_product_import.g.dart';

/// Counts produced by a validated product-import preview.
@Derive([Serialize(), Deserialize(), Eq()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminProductImportSummary with _$AdminProductImportSummary {
  /// Creates the explicit preview summary.
  const AdminProductImportSummary({
    required this.toCreate,
    required this.toUpdate,
  });

  /// Decodes the generated Admin response.
  factory AdminProductImportSummary.fromJson(Map<String, Object?> json) =>
      _$AdminProductImportSummaryFromJson(json);

  /// Unique products absent from the active catalogue.
  final int toCreate;

  /// Unique products already present in the active catalogue.
  final int toUpdate;
}

/// Medusa-shaped transaction returned without mutating the catalogue.
@Derive([Serialize(), Deserialize(), Eq()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminProductImportPreview with _$AdminProductImportPreview {
  /// Creates one staged import response.
  const AdminProductImportPreview({
    required this.transactionId,
    required this.summary,
  });

  /// Decodes the generated Admin response.
  factory AdminProductImportPreview.fromJson(Map<String, Object?> json) =>
      _$AdminProductImportPreviewFromJson(json);

  /// Counts shown before a later explicit confirmation.
  final AdminProductImportSummary summary;

  /// Opaque staged transaction identifier.
  final String transactionId;
}
