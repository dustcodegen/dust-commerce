import 'package:dust_dart/serde.dart';

part 'admin_product_media.g.dart';

/// One uploaded asset attached to a product during atomic creation.
@Derive([ToString(), Eq(), Validate(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminCreateProductMedia with _$AdminCreateProductMedia {
  /// Creates one ordered product-media input.
  const AdminCreateProductMedia({
    required this.id,
    required this.url,
    required this.isThumbnail,
  });

  /// Decodes the generated product-media input.
  factory AdminCreateProductMedia.fromJson(Map<String, Object?> json) =>
      _$AdminCreateProductMediaFromJson(json);

  /// Server-generated storage key returned by the upload endpoint.
  @Validate(length: Length(min: 1, max: 255), message: 'Choose an image')
  final String id;

  /// Whether this image is the product-card and cart thumbnail.
  final bool isThumbnail;

  /// Public URL returned with [id] by the upload endpoint.
  @Validate(length: Length(min: 1, max: 2048), message: 'Choose an image')
  final String url;
}

/// Complete ordered gallery replacement for one existing product.
@Derive([ToString(), Eq(), Validate(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminUpdateProductMedia with _$AdminUpdateProductMedia {
  /// Creates one atomic product-media replacement.
  const AdminUpdateProductMedia({required this.media});

  /// Decodes the generated product-media request.
  factory AdminUpdateProductMedia.fromJson(Map<String, Object?> json) =>
      _$AdminUpdateProductMediaFromJson(json);

  /// Existing image ids and staged upload keys in the desired display order.
  final List<AdminCreateProductMedia> media;
}
