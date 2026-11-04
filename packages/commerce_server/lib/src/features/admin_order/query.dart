import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_server/server.dart';

/// Validated Medusa-shaped order-list query.
final class AdminOrderQuery {
  /// Creates one normalized merchant query boundary.
  const AdminOrderQuery({
    required this.query,
    required this.statuses,
    required this.regionIds,
    required this.salesChannelIds,
    required this.customerId,
    required this.createdAt,
    required this.updatedAt,
    required this.order,
  });

  /// Order creation-time bounds.
  final AdminDateFilter createdAt;

  /// Customer owner constraint used by the customer-detail order section.
  final Option<String> customerId;

  /// Allowlisted table ordering.
  final AdminOrderOrder order;

  /// Free-text id, customer, or email search.
  final String query;

  /// Selected selling-region identifiers.
  final List<String> regionIds;

  /// Selected commercial-origin identifiers.
  final List<String> salesChannelIds;

  /// Selected order lifecycle states.
  final List<AdminOrderStatus> statuses;

  /// Order mutation-time bounds.
  final AdminDateFilter updatedAt;
}

/// Parses only the query capabilities represented by the local order schema.
Result<AdminOrderQuery, Rejection> adminOrderQueryOf(Request request) {
  final statuses = _statuses(request);
  if (statuses case Err(:final error)) return Err(error);
  final regionIds = _ids(request, 'region_id', 'region');
  if (regionIds case Err(:final error)) return Err(error);
  final salesChannelIds = _ids(
    request,
    'sales_channel_id',
    'sales channel',
  );
  if (salesChannelIds case Err(:final error)) return Err(error);
  final customerId = _customerId(request);
  if (customerId case Err(:final error)) return Err(error);
  final createdAt = _date(request, 'created_at');
  if (createdAt case Err(:final error)) return Err(error);
  final updatedAt = _date(request, 'updated_at');
  if (updatedAt case Err(:final error)) return Err(error);
  final order = AdminOrderOrder.parse(
    request.requestedUri.queryParameters['order'] ?? '-created_at',
  );
  if (order case None()) {
    return const Err(Rejection.badRequest('Unknown order sort'));
  }
  return Ok(AdminOrderQuery(
    query: request.requestedUri.queryParameters['q'] ?? '',
    statuses: (statuses as Ok<List<AdminOrderStatus>, Rejection>).value,
    regionIds: (regionIds as Ok<List<String>, Rejection>).value,
    salesChannelIds: (salesChannelIds as Ok<List<String>, Rejection>).value,
    customerId: (customerId as Ok<Option<String>, Rejection>).value,
    createdAt: (createdAt as Ok<AdminDateFilter, Rejection>).value,
    updatedAt: (updatedAt as Ok<AdminDateFilter, Rejection>).value,
    order: (order as Some<AdminOrderOrder>).value,
  ));
}

Result<Option<String>, Rejection> _customerId(Request request) {
  final value =
      (request.requestedUri.queryParameters['customer_id'] ?? '').trim();
  if (value.isEmpty) return const Ok(None());
  if (!RegExp(r'^[A-Za-z0-9_:-]{1,100}$').hasMatch(value)) {
    return const Err(Rejection.badRequest('Invalid customer id'));
  }
  return Ok(Some(value));
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

Result<List<AdminOrderStatus>, Rejection> _statuses(Request request) {
  final raw = request.requestedUri.queryParametersAll['status'] ?? const [];
  final values = raw
      .expand((entry) => entry.split(','))
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty);
  final result = <AdminOrderStatus>[];
  for (final value in values) {
    final matches = AdminOrderStatus.values.where(
        (status) => const AdminOrderStatusCodec().serialize(status) == value);
    if (matches.isEmpty) {
      return const Err(Rejection.badRequest('Unknown order status'));
    }
    if (!result.contains(matches.single)) result.add(matches.single);
  }
  return Ok(List.unmodifiable(result));
}

Result<List<String>, Rejection> _ids(
  Request request,
  String parameter,
  String label,
) {
  final raw = request.requestedUri.queryParametersAll[parameter] ?? const [];
  final values = raw
      .expand((entry) => entry.split(','))
      .map((id) => id.trim())
      .where((id) => id.isNotEmpty);
  final ids = values.toSet();
  final valid = RegExp(r'^[A-Za-z0-9_:-]{1,100}$');
  if (ids.length > 100 || ids.any((id) => !valid.hasMatch(id))) {
    return Err(Rejection.badRequest('Invalid $label ids'));
  }
  return Ok(List.unmodifiable(ids));
}
