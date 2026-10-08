import 'package:dust_dart/serde.dart';

part 'option_filter_view.g.dart';

/// One stable option value exposed by the store-wide refinement endpoint.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class ProductOptionValueView with _$ProductOptionValueView {
  /// Creates a public selectable value.
  const ProductOptionValueView({
    required this.id,
    required this.value,
    this.count = 0,
  });

  /// Creates a selectable value from the generated wire decoder.
  factory ProductOptionValueView.fromJson(Map<String, Object?> json) =>
      _$ProductOptionValueViewFromJson({'count': 0, ...json});

  /// Stable identifier used by the repeated `optionValueIds` query.
  final String id;

  /// Number of matching published products for this value.
  final int count;

  /// Customer-facing value, such as `Black` or `M`.
  final String value;
}

/// One product option and its stable values in the store refinement panel.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class ProductOptionFilterView with _$ProductOptionFilterView {
  /// Creates one public option filter.
  const ProductOptionFilterView({
    required this.id,
    required this.title,
    required this.values,
  });

  /// Creates an option filter from the generated wire decoder.
  factory ProductOptionFilterView.fromJson(Map<String, Object?> json) =>
      _$ProductOptionFilterViewFromJson(json);

  /// Stable option identifier.
  final String id;

  /// Customer-facing dimension, such as `Size` or `Color`.
  final String title;

  /// Active values belonging to this option.
  final List<ProductOptionValueView> values;
}

/// Public response for Medusa's `/store/product-options` refinement source.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class ProductOptionFilterListView with _$ProductOptionFilterListView {
  /// Creates a complete store refinement response.
  const ProductOptionFilterListView({
    required this.productOptions,
    required this.count,
  });

  /// Creates the response from the generated wire decoder.
  factory ProductOptionFilterListView.fromJson(Map<String, Object?> json) =>
      _$ProductOptionFilterListViewFromJson(json);

  /// Number of options returned.
  final int count;

  /// Explicit public option allowlists.
  final List<ProductOptionFilterView> productOptions;
}
