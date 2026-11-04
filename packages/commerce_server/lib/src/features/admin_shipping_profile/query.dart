import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_server/server.dart';

/// Validated shipping-profile table query shared by handler and service.
final class AdminShippingProfileQuery {
  /// Creates one normalized query boundary.
  const AdminShippingProfileQuery({
    required this.query,
    required this.name,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    required this.order,
  });

  /// Profile creation-time bounds.
  final AdminDateFilter createdAt;

  /// Exact table ordering from the public allowlist.
  final AdminShippingProfileOrder order;

  /// Dedicated profile-name search.
  final String name;

  /// Free-text name-or-type search.
  final String query;

  /// Dedicated fulfillment-type search.
  final String type;

  /// Profile update-time bounds.
  final AdminDateFilter updatedAt;
}

/// Parses the Medusa-shaped profile filter allowlist once.
Result<AdminShippingProfileQuery, Rejection> adminShippingProfileQueryOf(
  Request request,
) {
  final createdAt = _date(request, 'created_at');
  if (createdAt case Err(:final error)) return Err(error);
  final updatedAt = _date(request, 'updated_at');
  if (updatedAt case Err(:final error)) return Err(error);
  final order = AdminShippingProfileOrder.parse(
    request.requestedUri.queryParameters['order'] ?? 'name',
  );
  if (order case None()) {
    return const Err(Rejection.badRequest('Unknown shipping profile order'));
  }
  final parameters = request.requestedUri.queryParameters;
  return Ok(AdminShippingProfileQuery(
    query: parameters['q'] ?? '',
    name: parameters['name'] ?? '',
    type: parameters['type'] ?? '',
    createdAt: (createdAt as Ok<AdminDateFilter, Rejection>).value,
    updatedAt: (updatedAt as Ok<AdminDateFilter, Rejection>).value,
    order: (order as Some<AdminShippingProfileOrder>).value,
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
