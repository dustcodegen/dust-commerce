import 'package:commerce_server/src/features/admin_customer_group/list_repository.dart';
import 'package:commerce_server/src/features/admin_customer_group/repository/create.dart';
import 'package:commerce_server/src/features/admin_customer_group/repository/read.dart';
import 'package:commerce_server/src/http/http.dart';
import 'package:commerce_server/src/infra/database.dart';
import 'package:dust_server/server.dart';

/// Persistence required only by merchant customer-group routes.
final class AdminCustomerGroupDeps {
  /// Creates the focused group dependency bundle.
  const AdminCustomerGroupDeps({
    required this.groups,
    required this.creates,
    required this.details,
    required this.database,
    required this.clock,
  });

  /// Transaction boundary for updates that must return refreshed detail.
  final CommerceDatabase database;

  /// Protected customer-group creation.
  final AdminCustomerGroupCreateRepository creates;

  /// Protected customer-group detail reads.
  final AdminCustomerGroupDetailRepository details;

  /// Shared deterministic identifier source.
  final Clock clock;

  /// Protected customer-group list reads.
  final AdminCustomerGroupListRepository groups;
}

/// Extracts attached customer-group dependencies or a configuration failure.
Future<Result<AdminCustomerGroupDeps, Rejection>> adminCustomerGroupDeps(
  Request request,
) =>
    stateOf<AdminCustomerGroupDeps>(request);
