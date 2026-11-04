import 'package:commerce_server/src/features/customer_service/repository.dart';
import 'package:commerce_server/src/http/http.dart';
import 'package:dust_server/server.dart';

/// Persistence and identity generation for Store support submissions.
final class CustomerServiceDeps {
  /// Creates the focused dependency bundle.
  const CustomerServiceDeps({required this.requests, required this.nextId});

  /// Produces opaque request identifiers without owning application time.
  final String Function() nextId;

  /// Public write boundary for customer-service requests.
  final CustomerServiceRepository requests;
}

/// Extracts attached customer-service dependencies.
Future<Result<CustomerServiceDeps, Rejection>> customerServiceDeps(
  Request request,
) =>
    stateOf<CustomerServiceDeps>(request);
