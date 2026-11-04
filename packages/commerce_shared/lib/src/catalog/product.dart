import 'package:commerce_shared/src/catalog/category.dart';
import 'package:commerce_shared/src/catalog/collection.dart';
import 'package:commerce_shared/src/catalog/details.dart';
import 'package:commerce_shared/src/catalog/image.dart';
import 'package:commerce_shared/src/catalog/option.dart';
import 'package:commerce_shared/src/catalog/tag.dart';
import 'package:commerce_shared/src/catalog/variant.dart';
import 'package:commerce_shared/src/money.dart';
import 'package:dust_dart/serde.dart';

part 'product.g.dart';

/// Where a product sits in its publishing lifecycle.
///
/// Only [published] is visible to a storefront. The other three exist so an
/// operator can stage work without it leaking into the catalogue.
@Derive([Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
enum ProductStatus {
  /// Being written; never listed, never purchasable.
  draft,

  /// Submitted for review.
  proposed,

  /// Live in the storefront.
  published,

  /// Reviewed and refused.
  rejected;

  /// Whether a storefront should list a product in this state.
  bool get isVisible => this == ProductStatus.published;
}

/// A sellable item, and the options its variants vary along.
///
/// A product is not itself buyable — its variants are. The product holds what
/// is common: the name the storefront shows, the handle it routes on, and the
/// axes along which the variants differ.
@Derive([ToString(), Eq(), CopyWith(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
class Product with _$Product {
  /// Creates a [Product] from already-validated values.
  const Product({
    required this.id,
    required this.title,
    required this.handle,
    required this.status,
    required this.options,
    required this.variants,
    this.categories = const [],
    this.collection,
    this.details = const ProductDetails(),
    this.description,
    this.images = const [],
    this.thumbnail,
    this.tags = const [],
  });

  /// Creates a [Product], checking every variant against the declared options.
  ///
  /// Throws [ArgumentError] when two variants share an id, or when a variant
  /// chooses an option value the product does not offer — a combination
  /// nothing could ever render or price.
  factory Product.of({
    required String id,
    required String title,
    required String handle,
    ProductStatus status = ProductStatus.draft,
    ProductDetails details = const ProductDetails(),
    List<ProductCategory> categories = const [],
    ProductCollection? collection,
    String? description,
    List<StoreProductImage> images = const [],
    String? thumbnail,
    List<ProductTag> tags = const [],
    List<ProductOption> options = const [],
    List<ProductVariant> variants = const [],
  }) {
    final ids = variants.map((variant) => variant.id).toList();
    if (ids.toSet().length != ids.length) {
      throw ArgumentError.value(variants, 'variants', 'duplicate variant id');
    }
    for (final variant in variants) {
      _checkOptions(variant, options);
    }
    return Product(
      id: id,
      title: title,
      handle: _slugify(handle),
      status: status,
      categories: categories,
      collection: collection,
      details: details,
      description: description,
      images: images,
      thumbnail: thumbnail,
      tags: tags,
      options: options,
      variants: variants,
    );
  }

  /// Creates a [Product] from JSON.
  factory Product.fromJson(Map<String, Object?> json) =>
      _$ProductFromJson(json);

  /// Long-form copy.
  final String? description;

  /// Public categories this product appears in.
  final List<ProductCategory> categories;

  /// Curated collection this product belongs to, when any.
  final ProductCollection? collection;

  /// Physical and merchandising facts shown below the description.
  final ProductDetails details;

  /// URL-safe identifier the storefront routes on.
  final String handle;

  /// Unique identifier.
  final String id;

  /// Ordered images approved for the customer storefront.
  final List<StoreProductImage> images;

  /// The axes the variants vary along.
  final List<ProductOption> options;

  /// Publishing state.
  final ProductStatus status;

  /// Display name.
  final String title;

  /// Primary image.
  final String? thumbnail;

  /// Public discovery labels attached to this product.
  final List<ProductTag> tags;

  /// The buyable configurations.
  final List<ProductVariant> variants;

  /// Whether a customer can buy this right now.
  ///
  /// Published and at least one variant in stock. A published product whose
  /// every variant has sold out is listed but not purchasable, which is the
  /// distinction a storefront needs to show "sold out" rather than hide it.
  bool get isPurchasable =>
      status.isVisible && variants.any((variant) => variant.isInStock);

  /// Product-card image, matching Medusa's thumbnail-then-gallery fallback.
  String? get previewImageUrl =>
      thumbnail ?? (images.isEmpty ? null : images.first.url);

  /// The lowest price across variants in [currencyCode], or null.
  Money? cheapestIn(String currencyCode) {
    return cheapestVariantIn(currencyCode)?.priceIn(currencyCode);
  }

  /// The variant with the lowest active price in [currencyCode], or null.
  ProductVariant? cheapestVariantIn(String currencyCode) {
    ProductVariant? cheapest;
    for (final variant in variants) {
      final price = variant.priceIn(currencyCode);
      if (price == null) continue;
      final current = cheapest?.priceIn(currencyCode);
      if (current == null || price < current) cheapest = variant;
    }
    return cheapest;
  }

  /// Original price for the cheapest variant when that variant is on sale.
  Money? cheapestOriginalIn(String currencyCode) {
    final variant = cheapestVariantIn(currencyCode);
    if (variant == null || !variant.isOnSaleIn(currencyCode)) return null;
    return variant.originalPriceIn(currencyCode);
  }

  /// Whether any variant is discounted in [currencyCode].
  bool isOnSaleIn(String currencyCode) =>
      variants.any((variant) => variant.isOnSaleIn(currencyCode));

  /// The variant with [id], or null.
  ProductVariant? variantById(String id) {
    for (final variant in variants) {
      if (variant.id == id) return variant;
    }
    return null;
  }

  /// Images visible for the selected Medusa-compatible `v_id`.
  ///
  /// An unknown or unassociated variant falls back to the whole product
  /// gallery. Once a variant has associations, only those images are shown.
  List<StoreProductImage> imagesForVariant(String? variantId) {
    if (variantId == null) return images;
    final variant = variantById(variantId);
    if (variant == null || variant.images.isEmpty) return images;
    final visibleIds = variant.images.map((image) => image.id).toSet();
    return images
        .where((image) => visibleIds.contains(image.id))
        .toList(growable: false);
  }

  /// The variant matching every option value in [selection], or null.
  ProductVariant? variantFor(Map<String, String> selection) {
    for (final variant in variants) {
      final matches = selection.entries.every(
        (choice) => variant.optionValues[choice.key] == choice.value,
      );
      if (matches) return variant;
    }
    return null;
  }

  static void _checkOptions(
    ProductVariant variant,
    List<ProductOption> options,
  ) {
    for (final choice in variant.optionValues.entries) {
      final option = options.where((it) => it.id == choice.key).firstOrNull;
      if (option == null) {
        throw ArgumentError.value(
          choice.key,
          'variants',
          'variant ${variant.id} names an option the product does not declare',
        );
      }
      if (!option.offers(choice.value)) {
        throw ArgumentError.value(
          choice.value,
          'variants',
          'option ${option.title} does not offer this value',
        );
      }
    }
  }

  static final RegExp _separators = RegExp(r'[^a-z0-9]+');

  static String _slugify(String handle) {
    final slug = handle
        .toLowerCase()
        .replaceAll(_separators, '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    if (slug.isEmpty) {
      throw ArgumentError.value(handle, 'handle', 'leaves nothing to route on');
    }
    return slug;
  }
}
