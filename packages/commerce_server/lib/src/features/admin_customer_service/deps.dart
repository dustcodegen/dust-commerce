import 'package:commerce_server/src/features/admin_customer_service/repository.dart';
import 'package:commerce_server/src/http/http.dart';
import 'package:commerce_server/src/infra/database.dart';
import 'package:dust_server/server.dart';

/// Persistence owned only by the protected Admin support routes.
final class AdminCustomerServiceDeps {
  /// Creates the focused Admin dependency bundle.
  const AdminCustomerServiceDeps({
    required this.database,
    required this.requests,
  });

  /// Transaction boundary for lifecycle updates and refreshed responses.
  final CommerceDatabase database;

  /// Protected support request reads.
  final AdminCustomerServiceRepository requests;
}

/// Extracts attached Admin customer-service dependencies.
Future<Result<AdminCustomerServiceDeps, Rejection>> adminCustomerServiceDeps(
  Request request,
) =>
    stateOf<AdminCustomerServiceDeps>(request);
