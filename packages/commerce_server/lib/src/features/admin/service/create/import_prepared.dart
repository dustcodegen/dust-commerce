/// Business reason a staged import cannot be applied.
enum AdminProductImportConfirmFailure {
  /// The transaction does not belong to this administrator.
  notFound,

  /// The transaction was already consumed or has expired.
  unavailable,

  /// The staged rows no longer describe a valid catalogue graph.
  invalid,

  /// An id, handle, or SKU is now owned by another active record.
  conflict,
}

/// One product resolved against the current catalogue.
final class PreparedImportedProduct {
  /// Creates a product ready for deterministic writes.
  const PreparedImportedProduct({
    required this.id,
    required this.exists,
    required this.row,
    required this.variants,
  });

  /// Stable product id, newly allocated only when creating.
  final String id;

  /// Whether confirmation updates an existing active product.
  final bool exists;

  /// Validated product shell cells.
  final Map<String, String> row;

  /// Resolved variant rows.
  final List<PreparedImportedVariant> variants;
}

/// One variant resolved against the current catalogue.
final class PreparedImportedVariant {
  /// Creates a variant ready for deterministic writes.
  const PreparedImportedVariant({
    required this.id,
    required this.exists,
    required this.row,
    required this.prices,
  });

  /// Stable variant id, newly allocated only when creating.
  final String id;

  /// Whether confirmation updates an existing active variant.
  final bool exists;

  /// Validated variant cells.
  final Map<String, String> row;

  /// Exact minor-unit prices keyed by lowercase currency.
  final Map<String, int> prices;
}
