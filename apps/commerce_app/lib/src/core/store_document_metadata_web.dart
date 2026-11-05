import 'package:web/web.dart' as web;

/// Updates the browser metadata for the current storefront route.
void applyPlatformDocumentMetadata({
  required String title,
  required String description,
  required String canonicalUrl,
  required String structuredData,
  String? imageUrl,
}) {
  final document = web.document;
  document.title = title;
  _setMeta(document, name: 'description', content: description);
  _setMeta(document, property: 'og:title', content: title);
  _setMeta(document, property: 'og:description', content: description);
  _setMeta(document, property: 'og:url', content: canonicalUrl);
  if (imageUrl == null || imageUrl.isEmpty) {
    _removeMeta(document, property: 'og:image');
  } else {
    _setMeta(document, property: 'og:image', content: imageUrl);
  }
  _setCanonical(document, canonicalUrl);
  _setStructuredData(document, structuredData);
}

/// Restores the static shell metadata when the route is no longer a product.
void resetPlatformDocumentMetadata() {
  final document = web.document;
  document.title = 'Morrow';
  _setMeta(
    document,
    name: 'description',
    content: 'Morrow — everyday essentials, powered by dust.',
  );
  for (final property in const ['og:title', 'og:description', 'og:url']) {
    _removeMeta(document, property: property);
  }
  _removeMeta(document, property: 'og:image');
  document.querySelector('link[rel="canonical"]')?.remove();
  document.querySelector('script[data-dust-product-structured-data]')?.remove();
}

void _setCanonical(web.Document document, String href) {
  final existing = document.querySelector('link[rel="canonical"]');
  final link = existing == null
      ? (web.HTMLLinkElement()..rel = 'canonical')
      : existing as web.HTMLLinkElement;
  link.href = href;
  if (existing == null) document.head?.append(link);
}

void _setMeta(
  web.Document document, {
  String? name,
  String? property,
  required String content,
}) {
  final selector =
      name == null ? 'meta[property="$property"]' : 'meta[name="$name"]';
  final existing = document.querySelector(selector);
  final meta = existing == null
      ? (web.HTMLMetaElement()
        ..name = name ?? ''
        ..setAttribute('property', property ?? ''))
      : existing as web.HTMLMetaElement;
  meta.content = content;
  if (existing == null) document.head?.append(meta);
}

void _removeMeta(web.Document document, {required String property}) {
  document.querySelector('meta[property="$property"]')?.remove();
}

void _setStructuredData(web.Document document, String content) {
  final existing = document.querySelector(
    'script[data-dust-product-structured-data]',
  );
  final script = existing == null
      ? (web.HTMLScriptElement()
        ..type = 'application/ld+json'
        ..setAttribute('data-dust-product-structured-data', 'true'))
      : existing as web.HTMLScriptElement;
  script.text = content;
  if (existing == null) document.head?.append(script);
}
