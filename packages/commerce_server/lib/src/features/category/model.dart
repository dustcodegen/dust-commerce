import 'package:dust_dart/db.dart';
import 'package:dust_dart/serde.dart';

part 'model.g.dart';

/// Explicit public category response populated directly from its table.
@Derive([Serialize(), FromRow()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class ProductCategoryResponse with _$ProductCategoryResponse {
  /// Creates a public category response.
  const ProductCategoryResponse({
    required this.id,
    required this.name,
    required this.handle,
    this.description,
    this.parentId,
  });

  /// Optional customer-facing category copy.
  final String? description;

  /// Stable route path.
  final String handle;

  /// Stable category identifier.
  final String id;

  /// Customer-facing category name.
  final String name;

  /// Parent category identifier, absent for a root category.
  @Sqlx(rename: 'parent_category_id')
  final String? parentId;
}

/// Explicit category-list response.
@Derive([Serialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class ProductCategoryListResponse with _$ProductCategoryListResponse {
  /// Creates a category listing.
  const ProductCategoryListResponse({
    required this.categories,
    required this.count,
  });

  /// Explicit public category allowlists.
  final List<ProductCategoryResponse> categories;

  /// Number of returned categories.
  final int count;
}
