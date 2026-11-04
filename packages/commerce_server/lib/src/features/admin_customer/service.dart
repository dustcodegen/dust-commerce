import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin_customer/model.dart';
import 'package:commerce_server/src/features/admin_customer/repository.dart';
import 'package:dust_dart/db.dart';

/// Lists one bounded page of merchant-visible customer summaries.
Future<Result<AdminCustomerListResponse, SqlxError>> listAdminCustomers(
  AdminCustomerRepository customers, {
  required String query,
  required Option<String> groupId,
  required Option<bool> hasAccount,
  required AdminDateFilter createdAt,
  required AdminDateFilter updatedAt,
  required AdminCustomerOrder order,
  required int limit,
  required int offset,
}) async {
  final normalized = query.trim();
  final group = switch (groupId) {
    Some(:final value) => value,
    None() => '',
  };
  final account = switch (hasAccount) {
    Some(:final value) => value ? 1 : 0,
    None() => -1,
  };
  final page = await customers.list(
    normalized,
    account,
    _value(createdAt.greaterThan),
    _value(createdAt.greaterThanOrEqual),
    _value(createdAt.lessThan),
    _value(createdAt.lessThanOrEqual),
    _value(updatedAt.greaterThan),
    _value(updatedAt.greaterThanOrEqual),
    _value(updatedAt.lessThan),
    _value(updatedAt.lessThanOrEqual),
    group,
    order.parameter,
    limit,
    offset,
  );
  if (page case Err(:final error)) return Err(error);
  final count = await customers.count(
    normalized,
    account,
    _value(createdAt.greaterThan),
    _value(createdAt.greaterThanOrEqual),
    _value(createdAt.lessThan),
    _value(createdAt.lessThanOrEqual),
    _value(updatedAt.greaterThan),
    _value(updatedAt.greaterThanOrEqual),
    _value(updatedAt.lessThan),
    _value(updatedAt.lessThanOrEqual),
    group,
  );
  if (count case Err(:final error)) return Err(error);
  return Ok(AdminCustomerListResponse(
    customers: (page as Ok<List<AdminCustomerResponse>, SqlxError>).value,
    count: (count as Ok<int, SqlxError>).value,
    limit: limit,
    offset: offset,
  ));
}

String _value(Option<DateTime> value) => switch (value) {
      Some(value: final instant) => instant.toIso8601String(),
      None() => '',
    };
