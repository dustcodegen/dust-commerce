import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_server/server.dart';

/// Validated Medusa-shaped customer-list query.
final class AdminCustomerQuery {
  /// Creates one normalized merchant query boundary.
  const AdminCustomerQuery({
    required this.query,
    required this.groupId,
    required this.hasAccount,
    required this.createdAt,
    required this.updatedAt,
    required this.order,
  });

  /// Customer creation-time bounds.
  final AdminDateFilter createdAt;

  /// Active customer-group membership, or no group constraint.
  final Option<String> groupId;

  /// Registered/guest filter, or no account constraint.
  final Option<bool> hasAccount;

  /// Allowlisted table ordering.
  final AdminCustomerOrder order;

  /// Free-text id, email, company, or name search.
  final String query;

  /// Customer mutation-time bounds.
  final AdminDateFilter updatedAt;
}

/// Parses only query capabilities represented by the final customer table.
Result<AdminCustomerQuery, Rejection> adminCustomerQueryOf(Request request) {
  final hasAccount = _account(request);
  if (hasAccount case Err(:final error)) return Err(error);
  final createdAt = _date(request, 'created_at');
  if (createdAt case Err(:final error)) return Err(error);
  final updatedAt = _date(request, 'updated_at');
  if (updatedAt case Err(:final error)) return Err(error);
  final order = AdminCustomerOrder.parse(
    request.requestedUri.queryParameters['order'] ?? '-created_at',
  );
  if (order case None()) {
    return const Err(Rejection.badRequest('Unknown customer sort'));
  }
  return Ok(AdminCustomerQuery(
    query: request.requestedUri.queryParameters['q'] ?? '',
    groupId: switch (
        request.requestedUri.queryParameters['groups']?.trim() ?? '') {
      '' => const None(),
      final id => Some(id),
    },
    hasAccount: (hasAccount as Ok<Option<bool>, Rejection>).value,
    createdAt: (createdAt as Ok<AdminDateFilter, Rejection>).value,
    updatedAt: (updatedAt as Ok<AdminDateFilter, Rejection>).value,
    order: (order as Some<AdminCustomerOrder>).value,
  ));
}

Result<Option<bool>, Rejection> _account(Request request) {
  return switch (request.requestedUri.queryParameters['has_account'] ?? '') {
    '' => const Ok(None()),
    'true' => const Ok(Some(true)),
    'false' => const Ok(Some(false)),
    _ => const Err(Rejection.badRequest('Invalid account filter')),
  };
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
