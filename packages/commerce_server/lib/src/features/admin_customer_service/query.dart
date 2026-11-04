import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_server/server.dart';

/// Validated filter boundary for the Admin support inbox.
final class AdminCustomerServiceQuery {
  /// Creates one normalized merchant query.
  const AdminCustomerServiceQuery({
    required this.query,
    required this.statuses,
    required this.order,
  });

  /// Allowlisted table ordering.
  final AdminCustomerServiceOrder order;

  /// Free-text id, name, email, subject, or order-reference search.
  final String query;

  /// Selected triage lifecycle values.
  final List<AdminCustomerServiceStatus> statuses;
}

/// Parses only filters represented by the support request schema.
Result<AdminCustomerServiceQuery, Rejection> adminCustomerServiceQueryOf(
  Request request,
) {
  final query = (request.requestedUri.queryParameters['q'] ?? '').trim();
  if (query.length > 200) {
    return const Err(Rejection.badRequest('Support search is too long'));
  }
  final statuses = _statuses(request);
  if (statuses case Err(:final error)) return Err(error);
  final order = AdminCustomerServiceOrder.parse(
    request.requestedUri.queryParameters['order'] ?? '-created_at',
  );
  if (order case None()) {
    return const Err(Rejection.badRequest('Unknown support request sort'));
  }
  return Ok(AdminCustomerServiceQuery(
    query: query,
    statuses:
        (statuses as Ok<List<AdminCustomerServiceStatus>, Rejection>).value,
    order: (order as Some<AdminCustomerServiceOrder>).value,
  ));
}

Result<List<AdminCustomerServiceStatus>, Rejection> _statuses(
  Request request,
) {
  final raw = request.requestedUri.queryParametersAll['status'] ?? const [];
  final values = raw
      .expand((entry) => entry.split(','))
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty);
  final statuses = <AdminCustomerServiceStatus>[];
  for (final value in values) {
    try {
      final status = const AdminCustomerServiceStatusCodec().deserialize(value);
      if (!statuses.contains(status)) statuses.add(status);
    } on ArgumentError {
      return const Err(Rejection.badRequest('Unknown support request status'));
    }
  }
  return Ok(List.unmodifiable(statuses));
}
