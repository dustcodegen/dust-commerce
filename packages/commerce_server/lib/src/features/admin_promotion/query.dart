import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_server/server.dart';

/// Validated promotion-table query shared by handler and service.
final class AdminPromotionQuery {
  /// Creates one normalized query boundary.
  const AdminPromotionQuery({
    required this.query,
    required this.createdAt,
    required this.updatedAt,
    required this.order,
  });

  /// Promotion creation-time bounds.
  final AdminDateFilter createdAt;

  /// Allowlisted table ordering.
  final AdminPromotionOrder order;

  /// Free-text code search.
  final String query;

  /// Promotion update-time bounds.
  final AdminDateFilter updatedAt;
}

/// Parses the Medusa-shaped promotion filter allowlist once.
Result<AdminPromotionQuery, Rejection> adminPromotionQueryOf(Request request) {
  final createdAt = _date(request, 'created_at');
  if (createdAt case Err(:final error)) return Err(error);
  final updatedAt = _date(request, 'updated_at');
  if (updatedAt case Err(:final error)) return Err(error);
  final order = AdminPromotionOrder.parse(
    request.requestedUri.queryParameters['order'] ?? '-created_at',
  );
  if (order case None()) {
    return const Err(Rejection.badRequest('Unknown promotion order'));
  }
  return Ok(AdminPromotionQuery(
    query: request.requestedUri.queryParameters['q'] ?? '',
    createdAt: (createdAt as Ok<AdminDateFilter, Rejection>).value,
    updatedAt: (updatedAt as Ok<AdminDateFilter, Rejection>).value,
    order: (order as Some<AdminPromotionOrder>).value,
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
