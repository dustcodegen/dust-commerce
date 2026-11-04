import 'package:dust_server/server.dart';

/// HTTP methods used by the generated browser storefront client.
///
/// Keep this list beside the CORS policy rather than the executable so the
/// exact browser boundary is covered by tests. In particular, cart quantity
/// changes use `PATCH`; omitting it makes a healthy API look offline only in a
/// browser because the preflight is refused.
const storefrontCorsMethods = {
  'GET',
  'POST',
  'PATCH',
  'PUT',
  'DELETE',
  'OPTIONS',
};

/// Builds the production browser policy for the configured [origins].
Cors storefrontCors(Set<String> origins) => Cors(
      origins: AllowedOrigins.only(origins),
      methods: storefrontCorsMethods,
      headers: const {'accept', 'authorization', 'content-type'},
      maxAge: const Duration(minutes: 10),
    );
