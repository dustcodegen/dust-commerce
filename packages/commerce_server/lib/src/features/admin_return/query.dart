import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_server/server.dart';

/// Validated query for Medusa's order-detail return lookup.
final class AdminReturnQuery {
  /// Creates one normalized return query boundary.
  const AdminReturnQuery({required this.orderId, required this.statuses});

  /// Frozen order identifier, empty when all orders are requested.
  final String orderId;

  /// Selected return lifecycle states.
  final List<AdminReturnStatus> statuses;
}

/// Parses only filters represented by the local return schema and Admin UI.
Result<AdminReturnQuery, Rejection> adminReturnQueryOf(Request request) {
  final orderId =
      request.requestedUri.queryParameters['order_id']?.trim() ?? '';
  if (orderId.isNotEmpty &&
      !RegExp(r'^[A-Za-z0-9_:-]{1,100}$').hasMatch(orderId)) {
    return const Err(Rejection.badRequest('Invalid order id'));
  }
  final statuses = <AdminReturnStatus>[];
  final values = request.requestedUri.queryParametersAll['status'] ?? const [];
  for (final raw in values.expand((value) => value.split(','))) {
    final value = raw.trim();
    if (value.isEmpty) continue;
    try {
      final status = const AdminReturnStatusCodec().deserialize(value);
      if (!statuses.contains(status)) statuses.add(status);
    } on ArgumentError {
      return const Err(Rejection.badRequest('Unknown return status'));
    }
  }
  return Ok(AdminReturnQuery(
    orderId: orderId,
    statuses: List.unmodifiable(statuses),
  ));
}
