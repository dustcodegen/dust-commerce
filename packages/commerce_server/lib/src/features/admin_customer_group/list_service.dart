import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin_customer_group/list_repository.dart';
import 'package:commerce_server/src/features/admin_customer_group/list_response.dart';
import 'package:dust_dart/db.dart';

/// Lists one bounded page of merchant-visible customer-group summaries.
Future<Result<AdminCustomerGroupListResponse, SqlxError>>
    listAdminCustomerGroups(
  AdminCustomerGroupListRepository groups, {
  required String query,
  required AdminDateFilter createdAt,
  required AdminDateFilter updatedAt,
  required AdminCustomerGroupOrder order,
  required int limit,
  required int offset,
}) async {
  final values = _values(createdAt, updatedAt);
  final page = await groups.list(
    query.trim(),
    values[0],
    values[1],
    values[2],
    values[3],
    values[4],
    values[5],
    values[6],
    values[7],
    order.parameter,
    limit,
    offset,
  );
  if (page case Err(:final error)) return Err(error);
  final count = await groups.count(
    query.trim(),
    values[0],
    values[1],
    values[2],
    values[3],
    values[4],
    values[5],
    values[6],
    values[7],
  );
  if (count case Err(:final error)) return Err(error);
  return Ok(AdminCustomerGroupListResponse(
    customerGroups:
        (page as Ok<List<AdminCustomerGroupResponse>, SqlxError>).value,
    count: (count as Ok<int, SqlxError>).value,
    limit: limit,
    offset: offset,
  ));
}

List<String> _values(AdminDateFilter createdAt, AdminDateFilter updatedAt) => [
      _value(createdAt.greaterThan),
      _value(createdAt.greaterThanOrEqual),
      _value(createdAt.lessThan),
      _value(createdAt.lessThanOrEqual),
      _value(updatedAt.greaterThan),
      _value(updatedAt.greaterThanOrEqual),
      _value(updatedAt.lessThan),
      _value(updatedAt.lessThanOrEqual),
    ];

String _value(Option<DateTime> value) => switch (value) {
      Some(value: final instant) => instant.toIso8601String(),
      None() => '',
    };
