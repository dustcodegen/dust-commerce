import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_server/server.dart';

/// Validated product-table query shared by list and export routes.
final class AdminProductQuery {
  /// Creates one normalized query boundary.
  const AdminProductQuery({
    required this.query,
    required this.statuses,
    required this.tagIds,
    required this.typeIds,
    required this.createdAt,
    required this.updatedAt,
    required this.order,
  });

  /// Product creation-time bounds.
  final AdminDateFilter createdAt;

  /// Allowlisted table ordering.
  final AdminProductOrder order;

  /// Free-text title or handle search.
  final String query;

  /// Selected lifecycle states.
  final List<AdminProductLifecycle> statuses;

  /// Selected discovery-tag identifiers.
  final List<String> tagIds;

  /// Selected product-type identifiers.
  final List<String> typeIds;

  /// Product update-time bounds.
  final AdminDateFilter updatedAt;
}

/// Parses the public Medusa-shaped product filter allowlist once.
Result<AdminProductQuery, Rejection> adminProductQueryOf(Request request) {
  final statuses = _statuses(request);
  if (statuses case Err(:final error)) return Err(error);
  final tagIds = _ids(request, 'tag_id', 'product tag');
  if (tagIds case Err(:final error)) return Err(error);
  final typeIds = _ids(request, 'type_id', 'product type');
  if (typeIds case Err(:final error)) return Err(error);
  final createdAt = _date(request, 'created_at');
  if (createdAt case Err(:final error)) return Err(error);
  final updatedAt = _date(request, 'updated_at');
  if (updatedAt case Err(:final error)) return Err(error);
  final order = AdminProductOrder.parse(
    request.requestedUri.queryParameters['order'] ?? '-created_at',
  );
  if (order case None()) {
    return const Err(Rejection.badRequest('Unknown product order'));
  }
  return Ok(AdminProductQuery(
    query: request.requestedUri.queryParameters['q'] ?? '',
    statuses: (statuses as Ok<List<AdminProductLifecycle>, Rejection>).value,
    tagIds: (tagIds as Ok<List<String>, Rejection>).value,
    typeIds: (typeIds as Ok<List<String>, Rejection>).value,
    createdAt: (createdAt as Ok<AdminDateFilter, Rejection>).value,
    updatedAt: (updatedAt as Ok<AdminDateFilter, Rejection>).value,
    order: (order as Some<AdminProductOrder>).value,
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

Result<List<AdminProductLifecycle>, Rejection> _statuses(Request request) {
  final raw = request.requestedUri.queryParameters['status'] ?? '';
  if (raw.isEmpty) return const Ok([]);
  final statuses = <AdminProductLifecycle>[];
  for (final value in raw.split(',')) {
    final matches = AdminProductLifecycle.values.where(
      (status) => status.name == value,
    );
    if (matches.isEmpty) {
      return const Err(Rejection.badRequest('Unknown product status'));
    }
    if (!statuses.contains(matches.single)) statuses.add(matches.single);
  }
  return Ok(List.unmodifiable(statuses));
}

Result<List<String>, Rejection> _ids(
  Request request,
  String parameter,
  String label,
) {
  final raw = request.requestedUri.queryParameters[parameter] ?? '';
  if (raw.isEmpty) return const Ok([]);
  final ids = raw.split(',');
  final valid = RegExp(r'^[A-Za-z0-9_:-]{1,100}$');
  if (ids.length > 100 || ids.any((id) => !valid.hasMatch(id))) {
    return Err(Rejection.badRequest('Invalid $label ids'));
  }
  return Ok(List.unmodifiable(ids.toSet()));
}
