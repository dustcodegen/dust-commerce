import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin_order/export_csv.dart';
import 'package:commerce_server/src/features/admin_order/export_repository.dart';
import 'package:dust_dart/db.dart';

/// Exports the complete order set matching the live Admin table query.
Future<Result<String, SqlxError>> exportAdminOrders(
  AdminOrderExportRepository exports, {
  required String query,
  required List<AdminOrderStatus> statuses,
  required List<String> regionIds,
  required List<String> salesChannelIds,
  required AdminDateFilter createdAt,
  required AdminDateFilter updatedAt,
  required AdminOrderOrder order,
}) async {
  var normalized = query.trim();
  if (normalized.startsWith('#')) normalized = normalized.substring(1);
  final rows = await exports.list(
    normalized,
    statuses
        .map((status) => const AdminOrderStatusCodec().serialize(status))
        .join(','),
    regionIds.join(','),
    salesChannelIds.join(','),
    _value(createdAt.greaterThan),
    _value(createdAt.greaterThanOrEqual),
    _value(createdAt.lessThan),
    _value(createdAt.lessThanOrEqual),
    _value(updatedAt.greaterThan),
    _value(updatedAt.greaterThanOrEqual),
    _value(updatedAt.lessThan),
    _value(updatedAt.lessThanOrEqual),
    order.parameter,
  );
  return switch (rows) {
    Ok(:final value) => Ok(adminOrderCsv(value)),
    Err(:final error) => Err(error),
  };
}

String _value(Option<DateTime> value) => switch (value) {
      Some(value: final instant) => instant.toIso8601String(),
      None() => '',
    };
