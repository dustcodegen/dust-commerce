import 'package:commerce_shared/commerce_shared.dart';

import 'store_document_metadata_platform.dart'
    if (dart.library.html) 'store_document_metadata_web.dart';

/// The public document metadata owned by the storefront route.
final class StoreDocumentMetadata {
  /// Creates document metadata.
  const StoreDocumentMetadata({
    required this.title,
    required this.description,
    required this.canonicalUrl,
    this.imageUrl,
  });

  /// Builds the source-shaped metadata for a product route.
  factory StoreDocumentMetadata.forProduct(Product product, Uri currentUri) {
    final description = product.description?.trim();
    return StoreDocumentMetadata(
      title: '${product.title} | Morrow',
      description: description == null || description.isEmpty
          ? product.title
          : description,
      canonicalUrl: _canonicalUrl(currentUri),
      imageUrl: product.thumbnail,
    );
  }

  /// Canonical page URL without variant query state.
  final String canonicalUrl;

  /// Search and social description.
  final String description;

  /// Product thumbnail used by Open Graph when available.
  final String? imageUrl;

  /// Browser document title.
  final String title;
}

String _canonicalUrl(Uri currentUri) {
  final value = currentUri.toString();
  final queryStart = value.indexOf('?');
  final fragmentStart = value.indexOf('#');
  var end = value.length;
  if (queryStart >= 0 && queryStart < end) end = queryStart;
  if (fragmentStart >= 0 && fragmentStart < end) end = fragmentStart;
  return value.substring(0, end);
}

/// Applies route metadata on platforms that expose a document head.
void applyStoreDocumentMetadata(StoreDocumentMetadata metadata) =>
    applyPlatformDocumentMetadata(
      title: metadata.title,
      description: metadata.description,
      canonicalUrl: metadata.canonicalUrl,
      imageUrl: metadata.imageUrl,
    );

/// Restores the shell metadata when leaving a product route.
void resetStoreDocumentMetadata() => resetPlatformDocumentMetadata();
