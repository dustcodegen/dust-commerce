import 'package:dust_dart/serde.dart';

part 'collection.g.dart';

/// A curated product group exposed by the storefront.
@Derive([ToString(), Eq(), CopyWith(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class ProductCollection with _$ProductCollection {
  /// Creates an explicitly public collection.
  const ProductCollection({
    required this.id,
    required this.title,
    required this.handle,
  });

  /// Creates a collection from its wire representation.
  factory ProductCollection.fromJson(Map<String, Object?> json) =>
      _$ProductCollectionFromJson(json);

  /// Stable route segment.
  final String handle;

  /// Stable collection identifier.
  final String id;

  /// Customer-facing collection name.
  final String title;
}
