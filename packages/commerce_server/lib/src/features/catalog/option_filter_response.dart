import 'dart:convert';

import 'package:dust_dart/db.dart';
import 'package:dust_dart/serde.dart';

part 'option_filter_response.g.dart';

/// Explicit public option-value allowlist used by store refinements.
@Derive([Serialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class ProductOptionValueResponse with _$ProductOptionValueResponse {
  /// Creates one stable public value.
  const ProductOptionValueResponse({
    required this.id,
    required this.value,
    required this.count,
  });

  /// Stable value identifier accepted by product-list queries.
  final String id;

  /// Number of matching published products for this value.
  final int count;

  /// Customer-facing value label.
  final String value;
}

/// Explicit public option filter populated directly from SQLx.
@Derive([Serialize(), FromRow()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class ProductOptionFilterResponse with _$ProductOptionFilterResponse {
  /// Creates one complete public filter.
  const ProductOptionFilterResponse({
    required this.id,
    required this.title,
    required this.values,
  });

  /// Stable option identifier.
  final String id;

  /// Customer-facing option title.
  final String title;

  /// Explicit active values belonging to this option.
  @Sqlx(tryFrom: ProductOptionValuesFromJson())
  final List<ProductOptionValueResponse> values;
}

/// Explicit response envelope for store-wide product options.
@Derive([Serialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class ProductOptionFilterListResponse
    with _$ProductOptionFilterListResponse {
  /// Creates a complete option-filter listing.
  const ProductOptionFilterListResponse({
    required this.productOptions,
    required this.count,
  });

  /// Number of returned options.
  final int count;

  /// Explicit option filter allowlists.
  final List<ProductOptionFilterResponse> productOptions;
}

/// Decodes the ordered JSON array selected by the option-filter query.
final class ProductOptionValuesFromJson
    implements SqlxTryFrom<List<ProductOptionValueResponse>, String> {
  /// Creates the stateless converter.
  const ProductOptionValuesFromJson();

  @override
  List<ProductOptionValueResponse> decode(String value) {
    return [
      for (final item in jsonDecode(value) as List<Object?>)
        _value(item! as Map<String, Object?>),
    ];
  }

  static ProductOptionValueResponse _value(Map<String, Object?> value) =>
      ProductOptionValueResponse(
        id: value['id']! as String,
        value: value['value']! as String,
        count: value['count']! as int,
      );
}
