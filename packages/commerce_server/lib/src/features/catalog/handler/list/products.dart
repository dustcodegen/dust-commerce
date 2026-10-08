import 'package:commerce_server/src/features/catalog/deps.dart';
import 'package:commerce_server/src/features/catalog/model.dart';
import 'package:commerce_server/src/features/catalog/service/service.dart';
import 'package:commerce_server/src/http/http.dart';
import 'package:dust_server/server.dart';

/// `GET /products` — a page of the published catalogue.
Future<Result<ProductPageResponse, Rejection>> listProductsHandler(
  Request request,
) async {
  final state = await catalogDeps(request);
  if (state case Err(:final error)) return Err(error);
  final deps = (state as Ok<CatalogDeps, Rejection>).value;

  final paging = pagingOf(request);
  final search = queryOptionOf(request, 'q');
  if (search case Some(:final value) when value.length > 120) {
    return const Err(Rejection.badRequest('Product search is too long'));
  }
  final minPrice = priceQueryOf(request, 'minPrice');
  if (minPrice case Err(:final error)) return Err(error);
  final maxPrice = priceQueryOf(request, 'maxPrice');
  if (maxPrice case Err(:final error)) return Err(error);
  final sortBy = _sortOf(request);
  if (sortBy case Err(:final error)) return Err(error);
  final result = await listProducts(
    deps.lists,
    deps.counts,
    currencyCode: currencyOf(request),
    query: search,
    collection: queryOptionOf(request, 'collection'),
    categoryHandles: queryValuesOf(request, 'category'),
    labels: _labelsOf(request),
    sortBy: (sortBy as Ok<String, Rejection>).value,
    minPrice: (minPrice as Ok<Option<int>, Rejection>).value,
    maxPrice: (maxPrice as Ok<Option<int>, Rejection>).value,
    onSale: queryToggleOf(request, 'onSale'),
    optionValueIds: queryValuesOf(request, 'optionValueIds'),
    limit: paging.limit,
    offset: paging.offset,
  );

  return switch (result) {
    Ok(value: final page) => Ok(page),
    Err() => const Err(Rejection.internal()),
  };
}

Result<String, Rejection> _sortOf(Request request) {
  final value = switch (queryOptionOf(request, 'sortBy')) {
    Some(:final value) => value,
    None() => 'relevance',
  };
  if (const {
    'relevance',
    'created_at',
    'price_asc',
    'price_desc',
    'title_asc',
    'title_desc',
  }.contains(value)) {
    return Ok(value);
  }
  return const Err(Rejection.badRequest('Unknown product sort'));
}

List<String> _labelsOf(Request request) {
  final labels = [...queryValuesOf(request, 'labels')];
  if (queryOptionOf(request, 'tag') case Some(:final value)) {
    labels.add(value);
  }
  return labels;
}
