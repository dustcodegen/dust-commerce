import 'package:dust_dart/serde.dart';

part 'admin_product_image.g.dart';

/// One image intentionally exposed to the merchant product detail.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminProductImage with _$AdminProductImage {
  /// Creates an ordered merchant image.
  const AdminProductImage({
    required this.id,
    required this.url,
    required this.variantIds,
  });

  /// Decodes one generated admin image response.
  factory AdminProductImage.fromJson(Map<String, Object?> json) =>
      _$AdminProductImageFromJson(json);

  /// Stable image identifier used by media mutations.
  final String id;

  /// Merchant asset URL.
  final String url;

  /// Variants that exclusively display this image; empty means every variant.
  final List<String> variantIds;
}
