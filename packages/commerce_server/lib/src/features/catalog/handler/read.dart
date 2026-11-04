import 'package:commerce_server/src/features/catalog/deps.dart';
import 'package:commerce_server/src/features/catalog/model.dart';
import 'package:commerce_server/src/features/catalog/service/service.dart';
import 'package:commerce_server/src/http/http.dart';
import 'package:dust_server/server.dart';

/// `GET /products/{handle}` — one published product.
///
/// A draft answers 404 rather than 403. Telling an anonymous caller that a
/// handle exists but is not theirs to see leaks the catalogue before launch,
/// and the service returning null for both cases makes that automatic.
Future<Result<ProductResponse, Rejection>> readProductHandler(
  Request request,
) async {
  final handle = pathParametersOf(request)['handle'];
  if (handle == null || handle.isEmpty) {
    return const Err(Rejection.badRequest('A product handle is required'));
  }

  final state = await catalogDeps(request);
  if (state case Err(:final error)) return Err(error);
  final deps = (state as Ok<CatalogDeps, Rejection>).value;

  final result = await findProduct(
    deps.reads,
    handle: handle,
    currencyCode: currencyOf(request),
  );

  return switch (result) {
    Ok(value: Some(value: final product)) => Ok(product),
    Ok(value: None()) => Err(Rejection.notFound('Product "$handle"')),
    Err() => const Err(Rejection.internal()),
  };
}
