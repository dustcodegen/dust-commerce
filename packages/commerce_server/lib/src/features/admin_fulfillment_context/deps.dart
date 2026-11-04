import 'package:commerce_server/src/features/admin_fulfillment_context/repository.dart';
import 'package:commerce_server/src/http/http.dart';
import 'package:dust_server/server.dart';

/// Persistence required only by Admin fulfillment choice routes.
final class AdminFulfillmentContextDeps {
  /// Creates the focused dependency bundle.
  const AdminFulfillmentContextDeps({required this.choices});

  /// Protected fulfillment choice reads.
  final AdminFulfillmentContextRepository choices;
}

/// Extracts attached fulfillment dependencies or rejects configuration errors.
Future<Result<AdminFulfillmentContextDeps, Rejection>>
    adminFulfillmentContextDeps(Request request) =>
        stateOf<AdminFulfillmentContextDeps>(request);
