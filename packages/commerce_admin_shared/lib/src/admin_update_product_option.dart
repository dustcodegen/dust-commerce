import 'package:dust_dart/serde.dart';

part 'admin_update_product_option.g.dart';

/// Complete editable product-option fields accepted by the merchant API.
@Derive([ToString(), Eq(), Validate(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminUpdateProductOption with _$AdminUpdateProductOption {
  /// Creates a product-option replacement in merchant display order.
  const AdminUpdateProductOption({
    required this.title,
    required this.values,
  });

  /// Decodes the generated request without handwritten JSON mapping.
  factory AdminUpdateProductOption.fromJson(Map<String, Object?> json) =>
      _$AdminUpdateProductOptionFromJson(json);

  /// Merchant-facing dimension name, such as Size.
  @Validate(length: Length(min: 1, max: 255), message: 'Enter an option name')
  @Validate(regex: r'.*\S.*', message: 'Enter an option name')
  final String title;

  /// Unique non-empty values in the desired storefront display order.
  final List<String> values;
}
