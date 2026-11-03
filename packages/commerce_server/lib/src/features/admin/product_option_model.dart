import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin/product_option_json.dart'
    as json;
import 'package:dust_dart/db.dart';
import 'package:dust_dart/serde.dart';

part 'product_option_model.g.dart';

/// One table row selected directly from the global option query.
@Derive([Serialize(), FromRow()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminProductOptionSummaryResponse
    with _$AdminProductOptionSummaryResponse {
  /// Creates an explicitly allowlisted merchant response.
  const AdminProductOptionSummaryResponse({
    required this.id,
    required this.title,
    required this.valueCount,
    required this.isExclusive,
  });

  /// Stable product-option identifier.
  final String id;

  /// False for every row in the current global-options route.
  @Sqlx(rename: 'is_exclusive')
  final bool isExclusive;

  /// Merchant-facing dimension name.
  final String title;

  /// Number of active global values.
  @Sqlx(rename: 'value_count')
  final int valueCount;
}

/// Global option rows plus their bounded-list metadata.
@Derive([Serialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminProductOptionListResponse
    with _$AdminProductOptionListResponse {
  /// Creates one merchant product-option page.
  const AdminProductOptionListResponse({
    required this.productOptions,
    required this.count,
    required this.limit,
    required this.offset,
  });

  /// Total rows matching the query.
  final int count;

  /// Maximum requested page size.
  final int limit;

  /// Number of matching rows skipped.
  final int offset;

  /// Explicit global option summaries.
  final List<AdminProductOptionSummaryResponse> productOptions;
}

/// Complete global option detail selected directly from one SQL row.
@Derive([Serialize(), FromRow()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminProductOptionDetailResponse
    with _$AdminProductOptionDetailResponse {
  /// Creates an allowlist without inheriting persistence fields.
  const AdminProductOptionDetailResponse({
    required this.id,
    required this.title,
    required this.isExclusive,
    required this.values,
    required this.products,
  });

  /// Stable product-option identifier.
  final String id;

  /// Whether one product owns the option.
  @Sqlx(rename: 'is_exclusive')
  final bool isExclusive;

  /// Active products currently using this option.
  @Sqlx(tryFrom: _ProductOptionProductsSqlxJson())
  final List<AdminProduct> products;

  /// Merchant-facing dimension name.
  final String title;

  /// Active values in merchant-defined display order.
  @Sqlx(tryFrom: _ProductOptionValuesSqlxJson())
  final List<AdminProductOptionValue> values;
}

/// Minimal direct row used while attaching a new value to linked products.
@Derive([FromRow()])
final class AdminProductOptionLink {
  /// Creates the one-column persistence projection.
  const AdminProductOptionLink({required this.id});

  /// Stable product-option link identifier.
  final String id;
}

final class _ProductOptionValuesSqlxJson
    implements SqlxTryFrom<List<AdminProductOptionValue>, String> {
  const _ProductOptionValuesSqlxJson();

  @override
  List<AdminProductOptionValue> decode(String value) =>
      const json.AdminProductOptionValuesFromJson().decode(value);
}

final class _ProductOptionProductsSqlxJson
    implements SqlxTryFrom<List<AdminProduct>, String> {
  const _ProductOptionProductsSqlxJson();

  @override
  List<AdminProduct> decode(String value) =>
      const json.AdminProductOptionProductsFromJson().decode(value);
}
