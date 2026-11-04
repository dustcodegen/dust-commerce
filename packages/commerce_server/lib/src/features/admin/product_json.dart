import 'dart:convert';

import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin_shipping_profile/model.dart';
import 'package:dust_dart/db.dart';

/// Decodes an optional product shipping profile selected as JSON.
final class AdminProductShippingProfileFromJson
    implements SqlxTryFrom<AdminShippingProfileResponse?, String> {
  /// Creates the stateless converter.
  const AdminProductShippingProfileFromJson();

  @override
  AdminShippingProfileResponse? decode(String value) {
    final decoded = jsonDecode(value);
    return decoded == null
        ? null
        : AdminShippingProfileResponse.fromJson(
            decoded as Map<String, Object?>,
          );
  }
}

/// Decodes ordered product sales-channel objects selected as JSON.
final class AdminProductSalesChannelsFromJson
    implements SqlxTryFrom<List<AdminSalesChannel>, String> {
  /// Creates the stateless converter.
  const AdminProductSalesChannelsFromJson();

  @override
  List<AdminSalesChannel> decode(String value) => [
        for (final item in _array(value))
          AdminSalesChannel.fromJson(item! as Map<String, Object?>),
      ];
}

/// Decodes ordered product image objects selected as JSON.
final class AdminProductImagesFromJson
    implements SqlxTryFrom<List<AdminProductImage>, String> {
  /// Creates the stateless converter.
  const AdminProductImagesFromJson();

  @override
  List<AdminProductImage> decode(String value) => [
        for (final item in _array(value))
          AdminProductImage.fromJson(item! as Map<String, Object?>),
      ];
}

/// Decodes ordered product options selected as JSON.
final class AdminProductOptionsFromJson
    implements SqlxTryFrom<List<AdminProductOption>, String> {
  /// Creates the stateless converter.
  const AdminProductOptionsFromJson();

  @override
  List<AdminProductOption> decode(String value) => [
        for (final item in _array(value))
          AdminProductOption.fromJson(item! as Map<String, Object?>),
      ];
}

/// Decodes ordered inventory variants selected as JSON.
final class AdminProductVariantsFromJson
    implements SqlxTryFrom<List<AdminProductVariant>, String> {
  /// Creates the stateless converter.
  const AdminProductVariantsFromJson();

  @override
  List<AdminProductVariant> decode(String value) => [
        for (final item in _array(value))
          AdminProductVariant.fromJson(item! as Map<String, Object?>),
      ];
}

/// Decodes an ordered JSON string list.
final class AdminProductStringsFromJson
    implements SqlxTryFrom<List<String>, String> {
  /// Creates the stateless converter.
  const AdminProductStringsFromJson();

  @override
  List<String> decode(String value) => [
        for (final item in _array(value)) item! as String,
      ];
}

List<Object?> _array(String value) => jsonDecode(value) as List<Object?>;
