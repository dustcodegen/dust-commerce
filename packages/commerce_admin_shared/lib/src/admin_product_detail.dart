import 'package:commerce_admin_shared/src/admin_product.dart';
import 'package:commerce_admin_shared/src/admin_product_image.dart';
import 'package:commerce_admin_shared/src/admin_product_variant.dart';
import 'package:commerce_admin_shared/src/admin_option.dart';
import 'package:commerce_admin_shared/src/admin_shipping_profile.dart';
import 'package:dust_dart/serde.dart';

part 'admin_product_detail.g.dart';

/// Complete allowlisted merchant product detail.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminProductDetail with _$AdminProductDetail {
  /// Creates one product detail without inheriting database internals.
  const AdminProductDetail({
    required this.id,
    required this.title,
    required this.handle,
    required this.status,
    required this.images,
    required this.options,
    required this.variants,
    required this.categories,
    required this.tags,
    required this.discountable,
    this.description,
    this.subtitle,
    this.thumbnail,
    this.material,
    this.originCountry,
    this.productType,
    this.productTypeId,
    this.shippingProfileValue,
    this.collectionTitle,
    this.weight,
    this.length,
    this.width,
    this.height,
  });

  /// Decodes the generated admin detail response.
  factory AdminProductDetail.fromJson(Map<String, Object?> json) =>
      _$AdminProductDetailFromJson(json);

  /// Public categories assigned to the product.
  final List<String> categories;

  /// Optional curated collection label.
  final String? collectionTitle;

  /// Optional long-form merchant description.
  final String? description;

  /// Whether promotions may reduce this product's price.
  final bool discountable;

  /// Optional height in the store's configured unit.
  final int? height;

  /// Stable storefront route segment.
  final String handle;

  /// Stable product identifier.
  final String id;

  /// Ordered merchant media.
  final List<AdminProductImage> images;

  /// Optional length in the store's configured unit.
  final int? length;

  /// Optional merchant material description.
  final String? material;

  /// Ordered selectable dimensions.
  final List<AdminProductOption> options;

  /// Optional ISO 3166-1 alpha-2 country code.
  final String? originCountry;

  /// Optional merchant product classification.
  final String? productType;

  /// Stable classification identifier used by Admin mutation contracts.
  final String? productTypeId;

  /// Nullable JSON backing for [shippingProfile].
  @SerDe(rename: 'shipping_profile')
  final AdminShippingProfile? shippingProfileValue;

  /// Optional fulfillment behavior without nullable business state.
  Option<AdminShippingProfile> get shippingProfile =>
      adminOptionOf(shippingProfileValue);

  /// Merchant lifecycle state.
  @SerDe(using: AdminProductLifecycleCodec())
  final AdminProductLifecycle status;

  /// Optional secondary merchant-facing product name.
  final String? subtitle;

  /// Public discovery tags assigned to the product.
  final List<String> tags;

  /// Optional primary merchant image.
  final String? thumbnail;

  /// Merchant-facing product name.
  final String title;

  /// Inventory-bearing variants.
  final List<AdminProductVariant> variants;

  /// Optional weight in the store's configured unit.
  final int? weight;

  /// Optional width in the store's configured unit.
  final int? width;
}
