import 'dart:convert';

import 'package:commerce_server/src/features/catalog/model.dart';
import 'package:commerce_server/src/features/catalog/repository/repository.dart';
import 'package:commerce_server/src/infra/option.dart';
import 'package:dust_dart/db.dart';

/// Lists complete published product responses in [currencyCode].
Future<Result<ProductPageResponse, SqlxError>> listProducts(
  CatalogListRepository lists,
  CatalogCountRepository counts, {
  required String currencyCode,
  Option<String> query = const None(),
  Option<String> collection = const None(),
  List<String> categoryHandles = const [],
  List<String> labels = const [],
  String sortBy = 'relevance',
  Option<int> minPrice = const None(),
  Option<int> maxPrice = const None(),
  bool onSale = false,
  List<String> optionValueIds = const [],
  int limit = 20,
  int offset = 0,
}) async {
  final page = await lists.listPublished(
    currencyCode,
    limit,
    offset,
    nullableOf(query),
    nullableOf(collection),
    jsonEncode(categoryHandles),
    jsonEncode(labels),
    sortBy,
    nullableOf(minPrice),
    nullableOf(maxPrice),
    onSale ? 1 : 0,
    jsonEncode(optionValueIds),
  );
  if (page case Err(:final error)) return Err(error);

  final total = await counts.countPublished(
    currencyCode,
    nullableOf(query),
    nullableOf(collection),
    jsonEncode(categoryHandles),
    jsonEncode(labels),
    nullableOf(minPrice),
    nullableOf(maxPrice),
    onSale ? 1 : 0,
    jsonEncode(optionValueIds),
  );
  if (total case Err(:final error)) return Err(error);

  final products = (page as Ok<List<ProductResponse>, SqlxError>).value;
  return Ok(ProductPageResponse(
    products: products,
    count: products.length,
    total: (total as Ok<int, SqlxError>).value,
    limit: limit,
    offset: offset,
  ));
}
