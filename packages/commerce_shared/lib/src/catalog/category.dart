import 'package:dust_dart/serde.dart';

part 'category.g.dart';

/// One node in the public product-category hierarchy.
@Derive([ToString(), Eq(), CopyWith(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class ProductCategory with _$ProductCategory {
  /// Creates an explicitly public category.
  const ProductCategory({
    required this.id,
    required this.name,
    required this.handle,
    this.description,
    this.parentId,
  });

  /// Creates a category from its wire representation.
  factory ProductCategory.fromJson(Map<String, Object?> json) =>
      _$ProductCategoryFromJson(json);

  /// Optional customer-facing category copy.
  final String? description;

  /// Stable route path, including parent segments when nested.
  final String handle;

  /// Stable category identifier.
  final String id;

  /// Customer-facing category name.
  final String name;

  /// Parent category identifier, absent for a root category.
  final String? parentId;
}
