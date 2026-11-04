import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin/deps.dart';
import 'package:commerce_server/src/features/admin/handler/product_query.dart';
import 'package:commerce_server/src/features/admin/model.dart';
import 'package:commerce_server/src/features/admin/product_tag_model.dart';
import 'package:commerce_server/src/features/admin/product_type_model.dart';
import 'package:commerce_server/src/features/admin/service/service.dart';
import 'package:commerce_server/src/http/http.dart';
import 'package:dust_server/server.dart';

/// `GET /admin/products` — lists catalogue rows for a proven merchant.
Future<Result<AdminProductListResponse, Rejection>> listAdminProductsHandler(
  Request request,
) async {
  final state = await adminDeps(request);
  if (state case Err(:final error)) return Err(error);
  final deps = (state as Ok<AdminDeps, Rejection>).value;
  final paging = pagingOf(request);
  final query = adminProductQueryOf(request);
  if (query case Err(:final error)) return Err(error);
  final value = (query as Ok<AdminProductQuery, Rejection>).value;
  final result = await listAdminProducts(
    deps.products,
    query: value.query,
    statuses: value.statuses,
    tagIds: value.tagIds,
    typeIds: value.typeIds,
    createdAt: value.createdAt,
    updatedAt: value.updatedAt,
    order: value.order,
    limit: paging.limit,
    offset: paging.offset,
  );
  return switch (result) {
    Ok(:final value) => Ok(value),
    Err() => const Err(Rejection.internal()),
  };
}

/// `GET /admin/product-types` — lists filterable merchant classifications.
Future<Result<AdminProductTypeListResponse, Rejection>>
    listAdminProductTypesHandler(Request request) async {
  final state = await adminDeps(request);
  if (state case Err(:final error)) return Err(error);
  final deps = (state as Ok<AdminDeps, Rejection>).value;
  final paging = _filterOptionPagingOf(request);
  final result = await listAdminProductTypes(
    deps.productTypes,
    query: request.requestedUri.queryParameters['q'] ?? '',
    limit: paging.limit,
    offset: paging.offset,
  );
  return switch (result) {
    Ok(:final value) => Ok(value),
    Err() => const Err(Rejection.internal()),
  };
}

/// `GET /admin/product-tags` — lists filterable public discovery labels.
Future<Result<AdminProductTagListResponse, Rejection>>
    listAdminProductTagsHandler(Request request) async {
  final state = await adminDeps(request);
  if (state case Err(:final error)) return Err(error);
  final deps = (state as Ok<AdminDeps, Rejection>).value;
  final paging = _filterOptionPagingOf(request);
  final result = await listAdminProductTags(
    deps.productTags,
    query: request.requestedUri.queryParameters['q'] ?? '',
    limit: paging.limit,
    offset: paging.offset,
  );
  return switch (result) {
    Ok(:final value) => Ok(value),
    Err() => const Err(Rejection.internal()),
  };
}

({int limit, int offset}) _filterOptionPagingOf(Request request) {
  final query = request.requestedUri.queryParameters;
  final limit = int.tryParse(query['limit'] ?? '') ?? defaultLimit;
  final offset = int.tryParse(query['offset'] ?? '') ?? 0;
  return (limit: limit.clamp(1, 1000), offset: offset < 0 ? 0 : offset);
}

/// `GET /admin/products/create-context` — active pricing currencies.
Future<Result<AdminProductCreateContext, Rejection>>
    readAdminProductCreateContextHandler(
  Request request,
) async {
  final state = await adminDeps(request);
  if (state case Err(:final error)) return Err(error);
  final deps = (state as Ok<AdminDeps, Rejection>).value;
  final result = await readAdminProductCreateContext(deps.productCreates);
  return switch (result) {
    Ok(:final value) => Ok(value),
    Err() => const Err(Rejection.internal()),
  };
}
