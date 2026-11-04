import 'package:dust_server/server.dart';

/// Prevents stale or private API responses from entering a browser cache.
///
/// A handler can opt into a more specific policy, such as immutable product
/// media, by setting `cache-control` itself.
final class NoStoreByDefault implements Layer {
  /// Creates the API-wide safe default.
  const NoStoreByDefault();

  @override
  Middleware toMiddleware() => (inner) => (request) async {
        final response = await inner(request);
        if (response.headers.containsKey('cache-control')) return response;
        return response.change(headers: const {'cache-control': 'no-store'});
      };
}
