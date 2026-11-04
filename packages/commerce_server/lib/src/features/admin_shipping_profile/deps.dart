import 'package:commerce_server/src/features/admin_shipping_profile/repository.dart';
import 'package:commerce_server/src/features/admin_shipping_profile/management_repository.dart';
import 'package:commerce_server/src/http/http.dart';
import 'package:commerce_server/src/infra/database.dart';
import 'package:dust_server/server.dart';

/// Dependencies owned only by protected shipping-profile routes.
final class AdminShippingProfileDeps {
  /// Creates the focused fulfillment configuration bundle.
  const AdminShippingProfileDeps({
    required this.database,
    required this.profiles,
    required this.management,
    required this.clock,
  });

  /// Identifier source for durable product/profile links.
  final Clock clock;

  /// Transaction boundary for scalar assignment replacement.
  final CommerceDatabase database;

  /// Direct settings creation, detail, and deletion persistence.
  final AdminShippingProfileManagementRepository management;

  /// Direct profile discovery and assignment persistence.
  final AdminShippingProfileRepository profiles;
}

/// Extracts attached shipping-profile dependencies.
Future<Result<AdminShippingProfileDeps, Rejection>> adminShippingProfileDeps(
  Request request,
) =>
    stateOf<AdminShippingProfileDeps>(request);
