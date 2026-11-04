import 'package:dust_dart/serde.dart';

part 'admin_product_tag.g.dart';

/// One reusable discovery label visible to merchant clients.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminProductTag with _$AdminProductTag {
  /// Creates one explicit Admin API product-tag allowlist.
  const AdminProductTag({
    required this.id,
    required this.value,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Decodes one generated product-tag response.
  factory AdminProductTag.fromJson(Map<String, Object?> json) =>
      _$AdminProductTagFromJson(json);

  /// Database-generated creation instant.
  final DateTime createdAt;

  /// Stable discovery identifier used by product filters.
  final String id;

  /// Database-generated last-modified instant.
  final DateTime updatedAt;

  /// Merchant-facing discovery label.
  final String value;
}

/// One bounded Admin product-tag page.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminProductTagList with _$AdminProductTagList {
  /// Creates generated-client paging metadata and explicit rows.
  const AdminProductTagList({
    required this.productTags,
    required this.count,
    required this.limit,
    required this.offset,
  });

  /// Decodes one generated Admin API response.
  factory AdminProductTagList.fromJson(Map<String, Object?> json) =>
      _$AdminProductTagListFromJson(json);

  /// Total active rows matching the query.
  final int count;

  /// Maximum requested page size.
  final int limit;

  /// Number of matching rows skipped.
  final int offset;

  /// Direct allowlisted product-tag rows.
  final List<AdminProductTag> productTags;
}
