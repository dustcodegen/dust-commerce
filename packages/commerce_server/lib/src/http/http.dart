/// Reusable HTTP infrastructure: query parsing and state access.
///
/// There is no error shape here. Every refusal is a `Rejection` from
/// dust_server, which carries its own status and encodes to one JSON shape.
library;

export 'cache_policy.dart';
export 'cors.dart';
export 'paging.dart';
export 'state.dart';
export 'strict_json.dart';
