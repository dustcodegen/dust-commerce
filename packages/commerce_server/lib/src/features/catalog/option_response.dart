import 'package:dust_dart/serde.dart';

part 'option_response.g.dart';

/// Explicit public product-option response.
///
/// It intentionally does not extend the domain option, so internal domain
/// fields can never enter the wire response through inheritance.
@Derive([Serialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class ProductOptionResponse with _$ProductOptionResponse {
  /// Creates an explicitly allowlisted product option.
  const ProductOptionResponse({
    required this.id,
    required this.title,
    required this.values,
  });

  /// Stable option identifier.
  final String id;

  /// Customer-facing option name.
  final String title;

  /// Values a customer may choose.
  final List<String> values;
}
