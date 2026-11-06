import 'package:commerce_server/src/features/catalog/deps.dart';
import 'package:commerce_server/src/features/catalog/model.dart';
import 'package:commerce_server/src/features/catalog/service/service.dart';
import 'package:commerce_server/src/features/region/deps.dart';
import 'package:commerce_server/src/features/region/model.dart';
import 'package:commerce_server/src/features/region/service.dart';
import 'package:commerce_server/src/http/http.dart';
import 'package:commerce_shared/commerce_shared.dart';
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

/// Serves JSON products and the Medusa-compatible `.md` URL alias.
Future<Object?> readProductRouteHandler(Request request) {
  final handle = pathParametersOf(request)['handle'];
  if (handle?.endsWith('.md') == true || _acceptsMarkdown(request)) {
    return readProductMarkdownHandler(request);
  }
  return readProductHandler(request);
}

bool _acceptsMarkdown(Request request) {
  final accept = request.headers['accept'];
  if (accept == null) return false;
  return accept.split(',').any((value) {
    final parts = value.split(';');
    if (parts.first.trim().toLowerCase() != 'text/markdown') return false;
    for (final parameter in parts.skip(1)) {
      final fields = parameter.split('=');
      if (fields.first.trim().toLowerCase() != 'q') continue;
      if (fields.length != 2) return false;
      final quality = double.tryParse(fields.last.trim());
      return quality != null && quality > 0 && quality <= 1;
    }
    return true;
  });
}

/// `GET /products/{handle}/markdown` — a public Markdown product projection.
Future<Object?> readProductMarkdownHandler(Request request) async {
  final rawHandle = pathParametersOf(request)['handle'];
  final handle = rawHandle?.endsWith('.md') == true
      ? rawHandle!.substring(0, rawHandle.length - 3)
      : rawHandle;
  if (handle == null || handle.isEmpty) {
    return const Rejection.badRequest('A product handle is required');
  }

  final country = request.requestedUri.queryParameters['country']?.trim();
  if (country != null && !RegExp(r'^[A-Za-z]{2}$').hasMatch(country)) {
    return const Rejection.badRequest('country must be an ISO country code');
  }
  final countryCode = (country ?? 'us').toLowerCase();

  final catalogState = await catalogDeps(request);
  if (catalogState case Err(:final error)) return error;
  final catalog = (catalogState as Ok<CatalogDeps, Rejection>).value;

  var currencyCode = currencyOf(request);
  StoreRegionPolicy? policy;
  final regionState = await regionDeps(request);
  if (regionState case Err(:final error)) return error;
  final regions = await listSellingRegions(
    (regionState as Ok<RegionDeps, Rejection>).value.regions,
  );
  final SellingRegionListResponse listing;
  switch (regions) {
    case Err():
      return const Rejection.internal();
    case Ok(:final value):
      listing = value;
  }
  final region = listing.regions
      .where((candidate) => candidate.countries.contains(countryCode))
      .firstOrNull;
  if (region != null) {
    currencyCode = region.currencyCode;
    policy = region.policy;
  } else if (country != null && listing.regions.isNotEmpty) {
    return Rejection.notFound('Country "$countryCode"');
  }

  final productResult = await findProduct(
    catalog.reads,
    handle: handle,
    currencyCode: currencyCode,
  );
  final ProductResponse product;
  switch (productResult) {
    case Err():
      return const Rejection.internal();
    case Ok(value: None()):
      return Rejection.notFound('Product "$handle"');
    case Ok(value: Some(:final value)):
      product = value;
  }

  final origin = _requestOrigin(request);
  return Response(
    200,
    body: renderProductMarkdown(
      product,
      origin: origin,
      countryCode: countryCode,
      currencyCode: currencyCode,
      regionId: region?.id,
      policy: policy,
    ),
    headers: const {
      'cache-control':
          'public, max-age=0, s-maxage=60, stale-while-revalidate=600',
      'content-type': 'text/markdown; charset=utf-8',
      'vary': 'Accept',
    },
  );
}

String _requestOrigin(Request request) {
  final forwardedProto = request.headers['x-forwarded-proto'];
  final proto = forwardedProto == null || forwardedProto.isEmpty
      ? 'http'
      : forwardedProto.split(',').first.trim();
  final forwardedHost = request.headers['x-forwarded-host'];
  final host = forwardedHost == null || forwardedHost.isEmpty
      ? request.headers['host'] ?? 'localhost'
      : forwardedHost.split(',').first.trim();
  return '$proto://$host';
}
