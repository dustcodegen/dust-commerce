import 'package:commerce_server/src/features/catalog/option_filter_response.dart';
import 'package:commerce_server/src/features/catalog/repository/repository.dart';
import 'package:dust_dart/db.dart';

/// Lists public option refinements for the source store sidebar.
Future<Result<ProductOptionFilterListResponse, SqlxError>> listProductOptions(
  CatalogOptionRepository options, {
  int limit = 20,
  int offset = 0,
}) async {
  final result = await options.list(limit, offset);
  return switch (result) {
    Ok(:final value) => Ok(ProductOptionFilterListResponse(
        productOptions: value,
        count: value.length,
      )),
    Err(:final error) => Err(error),
  };
}
