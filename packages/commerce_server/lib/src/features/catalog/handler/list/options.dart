import 'package:commerce_server/src/features/catalog/deps.dart';
import 'package:commerce_server/src/features/catalog/option_filter_response.dart';
import 'package:commerce_server/src/features/catalog/service/service.dart';
import 'package:commerce_server/src/http/http.dart';
import 'package:dust_server/server.dart';

/// `GET /product-options` — active store-wide option refinements.
Future<Result<ProductOptionFilterListResponse, Rejection>>
    listProductOptionsHandler(Request request) async {
  final state = await catalogDeps(request);
  if (state case Err(:final error)) return Err(error);
  final deps = (state as Ok<CatalogDeps, Rejection>).value;
  final paging = pagingOf(request);

  final result = await listProductOptions(
    deps.options,
    limit: paging.limit,
    offset: paging.offset,
  );
  return switch (result) {
    Ok(:final value) => Ok(value),
    Err() => const Err(Rejection.internal()),
  };
}
