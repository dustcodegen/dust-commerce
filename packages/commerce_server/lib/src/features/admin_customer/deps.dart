import 'package:commerce_server/src/features/admin_customer/create_repository.dart';
import 'package:commerce_server/src/features/admin_customer/detail_repository.dart';
import 'package:commerce_server/src/features/admin_customer/repository.dart';
import 'package:commerce_server/src/http/http.dart';
import 'package:commerce_server/src/infra/database.dart';
import 'package:dust_server/server.dart';

/// Persistence required only by merchant customer routes.
final class AdminCustomerDeps {
  /// Creates the focused customer dependency bundle.
  const AdminCustomerDeps({
    required this.customers,
    required this.details,
    required this.creates,
    required this.clock,
    required this.database,
  });

  /// Protected customer-list reads.
  final AdminCustomerRepository customers;

  /// Protected complete profile reads.
  final AdminCustomerDetailRepository details;

  /// Protected customer-profile creation.
  final AdminCustomerCreateRepository creates;

  /// Deterministic identifier source shared by Admin commands.
  final Clock clock;

  /// Transaction boundary for ownership-safe profile replacement.
  final CommerceDatabase database;
}

/// Extracts attached customer dependencies or a configuration failure.
Future<Result<AdminCustomerDeps, Rejection>> adminCustomerDeps(
  Request request,
) =>
    stateOf<AdminCustomerDeps>(request);
