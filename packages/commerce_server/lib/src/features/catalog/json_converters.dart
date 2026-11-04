import 'dart:convert';

import 'package:commerce_server/src/features/catalog/option_response.dart';
import 'package:commerce_server/src/features/catalog/variant_response.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_dart/db.dart';

/// Decodes the public detail object selected as JSON.
final class ProductDetailsFromJson
    implements SqlxTryFrom<ProductDetails, String> {
  /// Creates the stateless converter.
  const ProductDetailsFromJson();

  @override
  ProductDetails decode(String value) =>
      ProductDetails.fromJson(_object(value));
}

/// Decodes the optional public collection selected as JSON.
final class ProductCollectionFromJson
    implements SqlxTryFrom<ProductCollection?, String> {
  /// Creates the stateless converter.
  const ProductCollectionFromJson();

  @override
  ProductCollection? decode(String value) {
    final decoded = jsonDecode(value);
    return decoded == null
        ? null
        : ProductCollection.fromJson(decoded as Map<String, Object?>);
  }
}

/// Decodes public categories selected as an ordered JSON array.
final class ProductCategoriesFromJson
    implements SqlxTryFrom<List<ProductCategory>, String> {
  /// Creates the stateless converter.
  const ProductCategoriesFromJson();

  @override
  List<ProductCategory> decode(String value) => [
        for (final item in _array(value))
          ProductCategory.fromJson(item! as Map<String, Object?>),
      ];
}

/// Decodes public tags selected as an ordered JSON array.
final class ProductTagsFromJson
    implements SqlxTryFrom<List<ProductTag>, String> {
  /// Creates the stateless converter.
  const ProductTagsFromJson();

  @override
  List<ProductTag> decode(String value) => [
        for (final item in _array(value))
          ProductTag.fromJson(item! as Map<String, Object?>),
      ];
}

/// Decodes ordered storefront images selected as JSON.
final class ProductImagesFromJson
    implements SqlxTryFrom<List<StoreProductImage>, String> {
  /// Creates the stateless converter.
  const ProductImagesFromJson();

  @override
  List<StoreProductImage> decode(String value) => [
        for (final item in _array(value))
          StoreProductImage.fromJson(item! as Map<String, Object?>),
      ];
}

/// Decodes explicit public product options selected as JSON.
final class ProductOptionsFromJson
    implements SqlxTryFrom<List<ProductOptionResponse>, String> {
  /// Creates the stateless converter.
  const ProductOptionsFromJson();

  @override
  List<ProductOptionResponse> decode(String value) => [
        for (final item in _array(value))
          _option(item! as Map<String, Object?>),
      ];

  static ProductOptionResponse _option(Map<String, Object?> item) =>
      ProductOptionResponse(
        id: item['id']! as String,
        title: item['title']! as String,
        values: [
          for (final value in item['values']! as List<Object?>)
            value! as String,
        ],
      );
}

/// Decodes currency-scoped public variants selected as JSON.
final class ProductVariantsFromJson
    implements SqlxTryFrom<List<ProductVariantResponse>, String> {
  /// Creates the stateless converter.
  const ProductVariantsFromJson();

  @override
  List<ProductVariantResponse> decode(String value) => [
        for (final item in _array(value))
          _variant(item! as Map<String, Object?>),
      ];

  static ProductVariantResponse _variant(Map<String, Object?> value) =>
      ProductVariantResponse(
        id: value['id']! as String,
        title: value['title']! as String,
        sku: value['sku'] as String?,
        prices: [
          Money(
            amount: value['amount']! as int,
            currencyCode: value['currency_code']! as String,
          ),
        ],
        originalPrices: [
          if (value['original_amount'] case final int amount)
            Money(
              amount: amount,
              currencyCode: value['currency_code']! as String,
            ),
        ],
        inventoryQuantity: value['inventory_quantity']! as int,
        manageInventory: value['manage_inventory']! as int != 0,
        allowBackorder: value['allow_backorder']! as int != 0,
        optionValues: (value['option_values']! as Map<String, Object?>).map(
          (key, choice) => MapEntry(key, choice! as String),
        ),
        images: [
          for (final image in value['images']! as List<Object?>)
            StoreProductImage.fromJson(image! as Map<String, Object?>),
        ],
      );
}

List<Object?> _array(String value) => jsonDecode(value) as List<Object?>;

Map<String, Object?> _object(String value) =>
    jsonDecode(value) as Map<String, Object?>;
