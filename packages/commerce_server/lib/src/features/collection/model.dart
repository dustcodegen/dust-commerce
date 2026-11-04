import 'package:dust_dart/db.dart';
import 'package:dust_dart/serde.dart';

part 'model.g.dart';

/// Explicit public collection response populated directly from its table.
@Derive([Serialize(), FromRow()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class ProductCollectionResponse with _$ProductCollectionResponse {
  /// Creates a public collection response.
  const ProductCollectionResponse({
    required this.id,
    required this.title,
    required this.handle,
  });

  /// Stable route segment.
  final String handle;

  /// Stable collection identifier.
  final String id;

  /// Customer-facing collection name.
  final String title;
}

/// Explicit collection-list response.
@Derive([Serialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class ProductCollectionListResponse with _$ProductCollectionListResponse {
  /// Creates a collection listing.
  const ProductCollectionListResponse({
    required this.collections,
    required this.count,
  });

  /// Number of returned collections.
  final int count;

  /// Explicit public collection allowlists.
  final List<ProductCollectionResponse> collections;
}
