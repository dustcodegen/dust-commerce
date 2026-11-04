import 'package:dust_dart/serde.dart';

part 'tag.g.dart';

/// A public product label used for filtering and discovery.
@Derive([ToString(), Eq(), CopyWith(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class ProductTag with _$ProductTag {
  /// Creates an explicitly public tag.
  const ProductTag({required this.id, required this.value});

  /// Creates a tag from its wire representation.
  factory ProductTag.fromJson(Map<String, Object?> json) =>
      _$ProductTagFromJson(json);

  /// Stable tag identifier.
  final String id;

  /// Customer-facing tag value.
  final String value;
}
