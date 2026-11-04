import 'dart:convert';

import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_dart/db.dart';
import 'package:dust_dart/serde.dart';

part 'line_item.g.dart';

/// Explicit line-item response populated directly by SQLx.
@Derive([Serialize(), FromRow()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class LineItemResponse with _$LineItemResponse {
  /// Creates an allowlisted line-item response.
  const LineItemResponse({
    required this.id,
    required this.variantId,
    required this.productId,
    required this.productHandle,
    required this.title,
    required this.unitPrice,
    required this.quantity,
    this.variantTitle,
    this.thumbnail,
  });

  /// Stable line identifier.
  final String id;

  /// Product route captured when the line was added.
  @Sqlx(rename: 'product_handle')
  final String productHandle;

  /// Product identifier captured when the line was added.
  @Sqlx(rename: 'product_id')
  final String productId;

  /// Quantity currently requested.
  final int quantity;

  /// Product image captured when the line was added.
  final String? thumbnail;

  /// Product title captured when the line was added.
  final String title;

  /// Price snapshot for one unit.
  @Sqlx(rename: 'unit_price', tryFrom: MoneyFromJson())
  final Money unitPrice;

  /// Variant identifier used for stock checks.
  @Sqlx(rename: 'variant_id')
  final String variantId;

  /// Variant title captured when the line was added.
  @Sqlx(rename: 'variant_title')
  final String? variantTitle;
}

/// Builds [Money] from a JSON object selected by SQLite.
final class MoneyFromJson implements SqlxTryFrom<Money, String> {
  /// Creates the stateless converter.
  const MoneyFromJson();

  @override
  Money decode(String value) => Money.fromJson(
        jsonDecode(value) as Map<String, Object?>,
      );
}
