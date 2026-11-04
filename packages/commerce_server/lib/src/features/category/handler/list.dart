import 'package:commerce_server/src/features/category/deps.dart';
import 'package:commerce_server/src/features/category/model.dart';
import 'package:commerce_server/src/features/category/service/service.dart';
import 'package:commerce_server/src/http/http.dart';
import 'package:dust_server/server.dart';

/// `GET /product-categories` — public active category hierarchy nodes.
Future<Result<ProductCategoryListResponse, Rejection>> listCategoriesHandler(
  Request request,
) async {
  final state = await categoryDeps(request);
  if (state case Err(:final error)) return Err(error);
  final deps = (state as Ok<CategoryDeps, Rejection>).value;
  final paging = pagingOf(request);

  final result = await listCategories(
    deps.categories,
    handle: queryOptionOf(request, 'handle'),
    limit: paging.limit,
    offset: paging.offset,
  );
  return switch (result) {
    Ok(:final value) => Ok(value),
    Err() => const Err(Rejection.internal()),
  };
}
