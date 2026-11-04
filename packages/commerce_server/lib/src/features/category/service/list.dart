import 'package:commerce_server/src/features/category/model.dart';
import 'package:commerce_server/src/features/category/repository/repository.dart';
import 'package:commerce_server/src/infra/option.dart';
import 'package:dust_dart/db.dart';

/// Lists public product categories with an optional full-handle filter.
Future<Result<ProductCategoryListResponse, SqlxError>> listCategories(
  ProductCategoryRepository categories, {
  Option<String> handle = const None(),
  int limit = 20,
  int offset = 0,
}) async {
  final result = await categories.list(nullableOf(handle), limit, offset);
  return switch (result) {
    Ok(:final value) => Ok(ProductCategoryListResponse(
        categories: value,
        count: value.length,
      )),
    Err(:final error) => Err(error),
  };
}
