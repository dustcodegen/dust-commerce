import 'package:dust_server/server.dart';

/// How many rows a listing returns when the caller does not say.
const int defaultLimit = 20;

/// The most a caller may ask for in one page.
///
/// A cap rather than an honoured request: without one, `?limit=1000000` is a
/// denial of service anybody can send.
const int maxLimit = 100;

/// The `limit` and `offset` a request asked for, clamped to what is allowed.
///
/// A value that is not a number, or is negative, falls back to the default
/// rather than failing the request. Paging is not the point of the call, and
/// rejecting a whole listing over a malformed query string serves nobody.
({int limit, int offset}) pagingOf(Request request) {
  final query = request.requestedUri.queryParameters;
  final limit = int.tryParse(query['limit'] ?? '') ?? defaultLimit;
  final offset = int.tryParse(query['offset'] ?? '') ?? 0;

  return (
    limit: limit.clamp(1, maxLimit),
    offset: offset < 0 ? 0 : offset,
  );
}

/// The currency a request asked to be priced in, lower case.
///
/// Defaults to [fallback] rather than failing, so a storefront that has not
/// picked a region yet still renders.
String currencyOf(Request request, {String fallback = 'usd'}) {
  final asked = request.requestedUri.queryParameters['currency'];
  if (asked == null || asked.length != 3) return fallback;
  return asked.toLowerCase();
}

/// A trimmed non-empty query value represented explicitly rather than null.
Option<String> queryOptionOf(Request request, String name) {
  final value = request.requestedUri.queryParameters[name]?.trim();
  return value == null || value.isEmpty
      ? const None<String>()
      : Some<String>(value);
}

/// Distinct, non-empty repeated query values, capped against request abuse.
List<String> queryValuesOf(Request request, String name) {
  final values = request.requestedUri.queryParametersAll[name] ?? const [];
  final normalized = <String>{};
  for (final raw in values) {
    for (final part in raw.split(',')) {
      final value = part.trim();
      if (value.isNotEmpty) normalized.add(value);
      if (normalized.length == maxLimit) return normalized.toList();
    }
  }
  return normalized.toList();
}

/// Whether a query toggle is explicitly enabled.
bool queryToggleOf(Request request, String name) {
  final value = request.requestedUri.queryParameters[name]?.trim();
  return value == 'true' || value == '1';
}

/// A non-negative minor-unit price query, represented explicitly.
Result<Option<int>, Rejection> priceQueryOf(Request request, String name) {
  final value = request.requestedUri.queryParameters[name]?.trim();
  if (value == null || value.isEmpty) return const Ok(None<int>());
  final parsed = int.tryParse(value);
  return parsed == null || parsed < 0
      ? Err(Rejection.badRequest('Invalid $name'))
      : Ok(Some<int>(parsed));
}
