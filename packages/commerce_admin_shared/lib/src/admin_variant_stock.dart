import 'package:dust_dart/serde.dart';

part 'admin_variant_stock.g.dart';

/// One selected variant's aggregate stock mutation.
@Derive([ToString(), Eq(), Validate(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminUpdateVariantStock with _$AdminUpdateVariantStock {
  /// Creates one stock-grid row mutation.
  const AdminUpdateVariantStock({
    required this.id,
    required this.inventoryQuantity,
    required this.manageInventory,
  });

  /// Decodes the generated Admin request.
  factory AdminUpdateVariantStock.fromJson(Map<String, Object?> json) =>
      _$AdminUpdateVariantStockFromJson(json);

  /// Stable selected variant identifier.
  @Validate(length: Length(min: 1), message: 'Choose a variant')
  final String id;

  /// Merchant-entered aggregate units on hand.
  @Validate(range: Range(min: 0), message: 'Enter non-negative stock')
  final int inventoryQuantity;

  /// Whether checkout enforces the aggregate units on hand.
  final bool manageInventory;
}

/// Atomic stock replacement for selected variants of one product.
@Derive([ToString(), Eq(), Validate(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminUpdateProductStock with _$AdminUpdateProductStock {
  /// Creates one product stock-grid mutation.
  const AdminUpdateProductStock({required this.variants});

  /// Decodes the generated Admin request.
  factory AdminUpdateProductStock.fromJson(Map<String, Object?> json) =>
      _$AdminUpdateProductStockFromJson(json);

  /// Selected rows saved together or not at all.
  final List<AdminUpdateVariantStock> variants;
}
