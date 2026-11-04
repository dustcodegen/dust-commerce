import 'package:commerce_admin_shared/src/admin_product_summary.dart';
import 'package:dust_dart/serde.dart';

part 'admin_product_option.g.dart';

/// One global option row shown in the merchant product-options table.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminProductOptionSummary with _$AdminProductOptionSummary {
  /// Creates a response containing only table-visible option fields.
  const AdminProductOptionSummary({
    required this.id,
    required this.title,
    required this.valueCount,
    required this.isExclusive,
  });

  /// Decodes the generated merchant response.
  factory AdminProductOptionSummary.fromJson(Map<String, Object?> json) =>
      _$AdminProductOptionSummaryFromJson(json);

  /// Stable product-option identifier.
  final String id;

  /// Whether the option is owned by one product instead of globally reusable.
  final bool isExclusive;

  /// Merchant-facing dimension name.
  final String title;

  /// Number of active values available for this option.
  final int valueCount;
}

/// Bounded page of merchant product options.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminProductOptionList with _$AdminProductOptionList {
  /// Creates one product-option result page.
  const AdminProductOptionList({
    required this.productOptions,
    required this.count,
    required this.limit,
    required this.offset,
  });

  /// Decodes the generated merchant response.
  factory AdminProductOptionList.fromJson(Map<String, Object?> json) =>
      _$AdminProductOptionListFromJson(json);

  /// Total number of global options matching the query.
  final int count;

  /// Maximum rows requested for this page.
  final int limit;

  /// Number of matching rows skipped.
  final int offset;

  /// Product options in stable newest-first order.
  final List<AdminProductOptionSummary> productOptions;
}

/// One stable value within a global product option.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminProductOptionValue with _$AdminProductOptionValue {
  /// Creates an explicitly allowlisted option value.
  const AdminProductOptionValue({
    required this.id,
    required this.value,
    required this.rank,
  });

  /// Decodes the generated merchant response.
  factory AdminProductOptionValue.fromJson(Map<String, Object?> json) =>
      _$AdminProductOptionValueFromJson(json);

  /// Stable value identifier retained by variants and orders.
  final String id;

  /// Merchant-defined display order.
  final int rank;

  /// Customer-visible choice label.
  final String value;
}

/// Complete global product-option detail exposed to the admin app.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminProductOptionDetail with _$AdminProductOptionDetail {
  /// Creates a safe response without inheriting persistence fields.
  const AdminProductOptionDetail({
    required this.id,
    required this.title,
    required this.isExclusive,
    required this.values,
    required this.products,
  });

  /// Decodes the generated merchant response.
  factory AdminProductOptionDetail.fromJson(Map<String, Object?> json) =>
      _$AdminProductOptionDetailFromJson(json);

  /// Stable product-option identifier.
  final String id;

  /// Whether the option belongs only to one product.
  final bool isExclusive;

  /// Explicitly allowlisted products currently using this option.
  final List<AdminProduct> products;

  /// Merchant-facing dimension name.
  final String title;

  /// Active values in merchant-defined display order.
  final List<AdminProductOptionValue> values;
}
