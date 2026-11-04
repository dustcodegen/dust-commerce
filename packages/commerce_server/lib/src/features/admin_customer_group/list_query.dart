import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_server/server.dart';

/// Validated Medusa-shaped customer-group list query.
final class AdminCustomerGroupQuery {
  /// Creates one normalized merchant query boundary.
  const AdminCustomerGroupQuery({
    required this.query,
    required this.createdAt,
    required this.updatedAt,
    required this.order,
  });

  /// Group creation-time bounds.
  final AdminDateFilter createdAt;

  /// Allowlisted table ordering.
  final AdminCustomerGroupOrder order;

  /// Free-text id or group-name search.
  final String query;

  /// Group mutation-time bounds.
  final AdminDateFilter updatedAt;
}

/// Parses only filters represented by the final customer-group table.
Result<AdminCustomerGroupQuery, Rejection> adminCustomerGroupQueryOf(
  Request request,
) {
  final createdAt = _date(request, 'created_at');
  if (createdAt case Err(:final error)) return Err(error);
  final updatedAt = _date(request, 'updated_at');
  if (updatedAt case Err(:final error)) return Err(error);
  final order = AdminCustomerGroupOrder.parse(
    request.requestedUri.queryParameters['order'] ?? '-created_at',
  );
  if (order case None()) {
    return const Err(Rejection.badRequest('Unknown customer group sort'));
  }
  return Ok(AdminCustomerGroupQuery(
    query: request.requestedUri.queryParameters['q'] ?? '',
    createdAt: (createdAt as Ok<AdminDateFilter, Rejection>).value,
    updatedAt: (updatedAt as Ok<AdminDateFilter, Rejection>).value,
    order: (order as Some<AdminCustomerGroupOrder>).value,
  ));
}

Result<AdminDateFilter, Rejection> _date(Request request, String name) {
  final parsed = AdminDateFilter.parse(
    request.requestedUri.queryParameters[name] ?? '',
  );
  return switch (parsed) {
    Some(:final value) => Ok(value),
    None() => Err(Rejection.badRequest('Invalid $name filter')),
  };
}
