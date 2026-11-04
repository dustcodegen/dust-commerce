import 'package:commerce_server/src/features/admin_sales_channel/repository.dart';
import 'package:commerce_server/src/http/http.dart';
import 'package:commerce_server/src/infra/database.dart';
import 'package:dust_server/server.dart';

/// Persistence required only by merchant sales-channel routes.
final class AdminSalesChannelDeps {
  /// Creates the focused sales-channel dependency bundle.
  const AdminSalesChannelDeps({
    required this.salesChannels,
    required this.database,
    required this.clock,
  });

  /// Shared identifier source for durable product-channel links.
  final Clock clock;

  /// Transaction boundary for complete assignment replacement.
  final CommerceDatabase database;

  /// Protected sales-channel discovery reads.
  final AdminSalesChannelRepository salesChannels;
}

/// Extracts attached sales-channel dependencies or a configuration failure.
Future<Result<AdminSalesChannelDeps, Rejection>> adminSalesChannelDeps(
  Request request,
) =>
    stateOf<AdminSalesChannelDeps>(request);
