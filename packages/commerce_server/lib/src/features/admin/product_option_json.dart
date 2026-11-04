import 'dart:convert';

import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/db.dart';

/// Decodes global option values selected as ordered JSON.
final class AdminProductOptionValuesFromJson
    implements SqlxTryFrom<List<AdminProductOptionValue>, String> {
  /// Creates the stateless converter.
  const AdminProductOptionValuesFromJson();

  @override
  List<AdminProductOptionValue> decode(String value) => [
        for (final item in _array(value))
          AdminProductOptionValue.fromJson(item! as Map<String, Object?>),
      ];
}

/// Decodes products using a global option from ordered JSON.
final class AdminProductOptionProductsFromJson
    implements SqlxTryFrom<List<AdminProduct>, String> {
  /// Creates the stateless converter.
  const AdminProductOptionProductsFromJson();

  @override
  List<AdminProduct> decode(String value) => [
        for (final item in _array(value))
          AdminProduct.fromJson(item! as Map<String, Object?>),
      ];
}

List<Object?> _array(String value) => jsonDecode(value) as List<Object?>;
