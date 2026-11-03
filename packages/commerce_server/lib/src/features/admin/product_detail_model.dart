import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin/product_json.dart' as json;
import 'package:commerce_server/src/features/admin_shipping_profile/model.dart';
import 'package:dust_dart/db.dart';
import 'package:dust_dart/serde.dart';

part 'product_detail_model.g.dart';

/// Complete product detail selected directly from one SQL row.
@Derive([Serialize(), FromRow()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminProductDetailResponse with _$AdminProductDetailResponse {
  /// Creates the explicitly allowlisted merchant detail response.
  const AdminProductDetailResponse({
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
    this.shippingProfile,
    this.collectionTitle,
    this.weight,
    this.length,
    this.width,
    this.height,
  });

  /// Public categories assigned to this product.
  @Sqlx()
  final List<String> categories;

  /// Optional curated collection label.
  @Sqlx(rename: 'collection_title')
  final String? collectionTitle;

  /// Optional long-form merchant description.
  final String? description;

  /// Whether promotions may reduce this product's price.
  @Sqlx()
  final bool discountable;

  /// Optional height in the store's configured unit.
  final int? height;

  /// Stable storefront route segment.
  final String handle;

  /// Stable product identifier.
  final String id;

  /// Ordered merchant media.
  @Sqlx(tryFrom: _AdminProductImagesSqlxJson())
  final List<AdminProductImage> images;

  /// Optional length in the store's configured unit.
  final int? length;

  /// Optional merchant material description.
  final String? material;

  /// Ordered selectable dimensions.
  @Sqlx(tryFrom: _AdminProductOptionsSqlxJson())
  final List<AdminProductOption> options;

  /// Optional ISO 3166-1 alpha-2 country code.
  @Sqlx(rename: 'origin_country')
  final String? originCountry;

  /// Optional merchant classification.
  @Sqlx(rename: 'product_type')
  final String? productType;

  /// Stable classification identifier used by Admin mutation contracts.
  @Sqlx(rename: 'product_type_id')
  final String? productTypeId;

  /// Current scalar fulfillment profile, when one remains active.
  @Sqlx(
    rename: 'shipping_profile',
    tryFrom: _AdminProductShippingProfileSqlxJson(),
  )
  final AdminShippingProfileResponse? shippingProfile;

  /// Merchant lifecycle state.
  @SerDe(using: AdminProductLifecycleCodec())
  @Sqlx(tryFrom: _AdminProductLifecycleSqlx())
  final AdminProductLifecycle status;

  /// Optional secondary merchant-facing product name.
  final String? subtitle;

  /// Public discovery tags assigned to this product.
  @Sqlx()
  final List<String> tags;

  /// Optional primary merchant image.
  final String? thumbnail;

  /// Merchant-facing product name.
  final String title;

  /// Inventory-bearing variants.
  @Sqlx(tryFrom: _AdminProductVariantsSqlxJson())
  final List<AdminProductVariant> variants;

  /// Optional weight in the store's configured unit.
  final int? weight;

  /// Optional width in the store's configured unit.
  final int? width;
}

final class _AdminProductImagesSqlxJson
    implements SqlxTryFrom<List<AdminProductImage>, String> {
  const _AdminProductImagesSqlxJson();
  @override
  List<AdminProductImage> decode(String value) =>
      const json.AdminProductImagesFromJson().decode(value);
}

final class _AdminProductShippingProfileSqlxJson
    implements SqlxTryFrom<AdminShippingProfileResponse?, String> {
  const _AdminProductShippingProfileSqlxJson();
  @override
  AdminShippingProfileResponse? decode(String value) =>
      const json.AdminProductShippingProfileFromJson().decode(value);
}

final class _AdminProductOptionsSqlxJson
    implements SqlxTryFrom<List<AdminProductOption>, String> {
  const _AdminProductOptionsSqlxJson();
  @override
  List<AdminProductOption> decode(String value) =>
      const json.AdminProductOptionsFromJson().decode(value);
}

final class _AdminProductVariantsSqlxJson
    implements SqlxTryFrom<List<AdminProductVariant>, String> {
  const _AdminProductVariantsSqlxJson();
  @override
  List<AdminProductVariant> decode(String value) =>
      const json.AdminProductVariantsFromJson().decode(value);
}

final class _AdminProductLifecycleSqlx
    implements SqlxTryFrom<AdminProductLifecycle, String> {
  const _AdminProductLifecycleSqlx();
  @override
  AdminProductLifecycle decode(String value) =>
      AdminProductLifecycle.values.byName(value);
}
