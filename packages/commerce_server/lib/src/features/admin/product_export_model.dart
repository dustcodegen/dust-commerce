import 'package:dust_dart/db.dart';

part 'product_export_model.g.dart';

/// One product graph selected directly for deterministic CSV expansion.
@Derive([FromRow()])
@Sqlx(renameAll: SqlxRename.snakeCase)
final class AdminProductExportRow {
  /// Creates the private database projection used only by product export.
  const AdminProductExportRow({
    required this.productId,
    required this.handle,
    required this.title,
    required this.status,
    required this.discountable,
    required this.optionsJson,
    required this.variantsJson,
    required this.imagesJson,
    required this.tagsJson,
    this.subtitle,
    this.description,
    this.thumbnail,
    this.weight,
    this.length,
    this.width,
    this.height,
    this.originCountry,
    this.material,
    this.collectionId,
    this.typeId,
  });

  /// Stable required product values and PostgreSQL JSON child graphs.
  // Grouped because these fields share one database representation.
  // ignore: public_member_api_docs, avoid_multiple_declarations_per_line
  final String productId, handle, title, status;
  // ignore: public_member_api_docs, avoid_multiple_declarations_per_line
  final String optionsJson, variantsJson, imagesJson, tagsJson;

  /// Optional product values represented as blank cells when absent.
  // Grouped because each value uses the same absent-cell policy.
  // ignore: public_member_api_docs, avoid_multiple_declarations_per_line
  final String? subtitle, description, thumbnail, originCountry;
  // ignore: public_member_api_docs, avoid_multiple_declarations_per_line
  final String? material, collectionId, typeId;

  /// PostgreSQL integer flag used without an intermediate ORM model.
  final int discountable;

  /// Optional physical values represented in the store's configured unit.
  // ignore: public_member_api_docs, avoid_multiple_declarations_per_line
  final int? weight, length, width, height;
}
