import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin_order/model.dart';
import 'package:commerce_server/src/features/admin_order/repository.dart';
import 'package:dust_dart/db.dart';

/// Lists one bounded page of merchant-visible immutable order summaries.
Future<Result<AdminOrderListResponse, SqlxError>> listAdminOrders(
  AdminOrderRepository orders, {
  required String query,
  required List<AdminOrderStatus> statuses,
  required List<String> regionIds,
  required List<String> salesChannelIds,
  required Option<String> customerId,
  required AdminDateFilter createdAt,
  required AdminDateFilter updatedAt,
  required AdminOrderOrder order,
  required int limit,
  required int offset,
}) async {
  var normalized = query.trim();
  if (normalized.startsWith('#')) normalized = normalized.substring(1);
  final page = await orders.list(
    normalized,
    statuses
        .map((status) => const AdminOrderStatusCodec().serialize(status))
        .join(','),
    regionIds.join(','),
    salesChannelIds.join(','),
    _optionalValue(customerId),
    _value(createdAt.greaterThan),
    _value(createdAt.greaterThanOrEqual),
    _value(createdAt.lessThan),
    _value(createdAt.lessThanOrEqual),
    _value(updatedAt.greaterThan),
    _value(updatedAt.greaterThanOrEqual),
    _value(updatedAt.lessThan),
    _value(updatedAt.lessThanOrEqual),
    order.parameter,
    limit,
    offset,
  );
  if (page case Err(:final error)) return Err(error);
  final count = await orders.count(
    normalized,
    statuses
        .map((status) => const AdminOrderStatusCodec().serialize(status))
        .join(','),
    regionIds.join(','),
    salesChannelIds.join(','),
    _optionalValue(customerId),
    _value(createdAt.greaterThan),
    _value(createdAt.greaterThanOrEqual),
    _value(createdAt.lessThan),
    _value(createdAt.lessThanOrEqual),
    _value(updatedAt.greaterThan),
    _value(updatedAt.greaterThanOrEqual),
    _value(updatedAt.lessThan),
    _value(updatedAt.lessThanOrEqual),
  );
  if (count case Err(:final error)) return Err(error);
  return Ok(AdminOrderListResponse(
    orders: (page as Ok<List<AdminOrderResponse>, SqlxError>).value,
    count: (count as Ok<int, SqlxError>).value,
    limit: limit,
    offset: offset,
  ));
}

String _value(Option<DateTime> value) => switch (value) {
      Some(value: final instant) => instant.toIso8601String(),
      None() => '',
    };

String _optionalValue(Option<String> value) => switch (value) {
      Some(:final value) => value,
      None() => '',
    };
