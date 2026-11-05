/// No-op document metadata implementation for non-web Flutter targets.
void applyPlatformDocumentMetadata({
  required String title,
  required String description,
  required String canonicalUrl,
  required String structuredData,
  String? imageUrl,
}) {}

/// Restores metadata on non-web targets.
void resetPlatformDocumentMetadata() {}
