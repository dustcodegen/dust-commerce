import 'package:dust_dart/serde.dart';

part 'admin_product_image_variants.g.dart';

/// Medusa-compatible add/remove batch for one product image.
@Derive([ToString(), Eq(), Validate(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminBatchImageVariants with _$AdminBatchImageVariants {
  /// Creates an idempotent association batch.
  const AdminBatchImageVariants({
    this.add = const [],
    this.remove = const [],
  });

  /// Decodes the generated request contract.
  factory AdminBatchImageVariants.fromJson(Map<String, Object?> json) =>
      _$AdminBatchImageVariantsFromJson(json);

  /// Variant identifiers to associate with the image.
  @SerDe(defaultValue: <String>[])
  final List<String> add;

  /// Variant identifiers to disassociate from the image.
  @SerDe(defaultValue: <String>[])
  final List<String> remove;
}

/// Exact association changes accepted by the server.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminBatchImageVariantsResult with _$AdminBatchImageVariantsResult {
  /// Creates the Medusa-compatible batch response.
  const AdminBatchImageVariantsResult({
    required this.added,
    required this.removed,
  });

  /// Decodes the generated response contract.
  factory AdminBatchImageVariantsResult.fromJson(Map<String, Object?> json) =>
      _$AdminBatchImageVariantsResultFromJson(json);

  /// Variant identifiers included in the add batch.
  final List<String> added;

  /// Variant identifiers included in the remove batch.
  final List<String> removed;
}
